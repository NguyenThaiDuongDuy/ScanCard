//
//  ViewController.swift
//  ScanCard
//
//  Created by admin on 05/04/2021.
//

import UIKit
import AVKit
import Vision

class ScanViewController: UIViewController {
    
    static let minCommonCardWidth:CGFloat = 333.0
    static let maxCommonCardWidth:CGFloat = 345.0
    static let minimumAspectRatioCard = VNAspectRatio(1.3)
    static let maximumAspectRatioCard = VNAspectRatio(1.6)
    static let maximum1TimeCardDetect = 1
    static let miniSizeDetectCard = Float(0.5)
    
    @IBOutlet weak var liveVideoView: PreviewView!
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var shadowView: PreviewView!
    
    var scanString = "Scan"
    var layer:CALayer!
    var vnRectangleObservation: VNRectangleObservation?
    var sampleBuffer:CMSampleBuffer?
    var recognizedStrings:[String]?
    
    lazy var cameraService:CameraService = {
        let mCameraService = CameraService(viewcontroller: self)
        return mCameraService
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = . white
        
        let tapAction = UITapGestureRecognizer(target: self, action: #selector(tap))
        self.liveVideoView.addGestureRecognizer(tapAction)
        setUpScanButton()
    }
    override func viewDidLayoutSubviews() {
        setupLiveView()
    }
    
    private func setupLiveView() {

        liveVideoView.videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        liveVideoView.videoPreviewLayer.cornerRadius = 30
        liveVideoView.videoPreviewLayer.masksToBounds = true
        liveVideoView.frame = shadowView.frame
        
    }
    
    @objc func tap() {
        DispatchQueue.main.async {
            self.cameraService.session.stopRunning()
            guard let mVNRectangleObservation = self.vnRectangleObservation,let mSampleBuffer = self.sampleBuffer else  {return}
            guard let imageBuffer = mSampleBuffer.imageBuffer else {return}
            let result =  self.extractPerspectiveRect(mVNRectangleObservation, from: imageBuffer)
            self.getCardInformation(ciimage: result)
            self.dismiss(animated: true) {
                self.cameraService.stopConnectCamera()
                let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                let vc: ScanTextViewController = mainStoryboard.instantiateViewController(withIdentifier: "ScanTextViewController") as! ScanTextViewController
                vc.cardImage = UIImage(ciImage: result)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func setUpScanButton() {
        scanButton.backgroundColor = .blue
        scanButton.setTitle(scanString, for: .normal)
        scanButton.tintColor = .white
        scanButton.layer.cornerRadius = scanButton.bounds.height/2
    }
    
    @IBAction func tapScanButton(_ sender: Any) {
        liveVideoView.videoPreviewLayer.session = cameraService.session
        cameraService.startConnectCamera()
        AuthorService.share.reQuestUsingCamera { (author) in
        }
    }
    
}



extension ScanViewController:AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func detecCard(sampleBuffer: CMSampleBuffer) {
        func detectRectanglesCompletionHandler (request: VNRequest, error: Error?) {
            DispatchQueue.main.async {
                //Request fail
                if let _ = error {
                    return
                }
                self.removeBoundingBox()
                guard let results = request.results as? [VNRectangleObservation] else { return }
                guard let rect = results.first else {return}
                
                self.vnRectangleObservation = rect
                self.sampleBuffer = sampleBuffer
                let convertUIKitrect = VNImageRectForNormalizedRect(rect.boundingBox,
                                                        (Int)(self.liveVideoView.bounds.width),
                                                        (Int)(self.liveVideoView.bounds.height))
                self.drawBoundingBox(rec: convertUIKitrect)
            }
        }
        
        let request = VNDetectRectanglesRequest(completionHandler:detectRectanglesCompletionHandler)
        request.minimumAspectRatio = ScanViewController.minimumAspectRatioCard
        request.maximumAspectRatio = ScanViewController.maximumAspectRatioCard
        request.minimumSize = ScanViewController.miniSizeDetectCard
        request.maximumObservations = ScanViewController.maximum1TimeCardDetect
        
        let requestHandler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, options: [:])
        
        try? requestHandler.perform([request])
    }
    
    func getCardInformation(ciimage:CIImage) {
        let request = VNRecognizeTextRequest { (request, error) in
            guard let observations =
                    request.results as? [VNRecognizedTextObservation] else {
                return
            }
            
            let recognizedStrings = observations.compactMap { observation in
                return observation.topCandidates(1).first?.string
            }
            
            self.recognizedStrings = recognizedStrings
            print(recognizedStrings)
        }
        request.recognitionLevel = .accurate
        
        
        //let rotateImage = ciimage.oriented(.right)
        let requestTextHandler = VNImageRequestHandler(ciImage: ciimage, options: [:])
        try? requestTextHandler.perform([request])
    }
    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        detecCard(sampleBuffer: sampleBuffer)
    }
    
    
    //Crop image in boundingbox
    private func extractPerspectiveRect(_ observation: VNRectangleObservation, from buffer: CVImageBuffer) -> CIImage {
        // get the pixel buffer into Core Image
        let ciImage = CIImage(cvImageBuffer: buffer)
        
        // convert corners from normalized image coordinates to pixel coordinates
        let topLeft = observation.topLeft.scaled(to: ciImage.extent.size)
        let topRight = observation.topRight.scaled(to: ciImage.extent.size)
        let bottomLeft = observation.bottomLeft.scaled(to: ciImage.extent.size)
        let bottomRight = observation.bottomRight.scaled(to: ciImage.extent.size)
        
        // pass those to the filter to extract/rectify the image
        return ciImage.applyingFilter("CIPerspectiveCorrection", parameters: [
            "inputTopLeft": CIVector(cgPoint: topLeft),
            "inputTopRight": CIVector(cgPoint: topRight),
            "inputBottomLeft": CIVector(cgPoint: bottomLeft),
            "inputBottomRight": CIVector(cgPoint: bottomRight),
        ])
    }
    
    
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        print("captureOutput didDorp")
    }
    
    private func drawBoundingBox(rec:CGRect) {
        layer = CAShapeLayer()
        layer.frame = rec
        layer.cornerRadius = 10
        layer.opacity = 0.75
        layer.borderColor = UIColor.red.cgColor
        layer.borderWidth = 5.0
        liveVideoView.layer.addSublayer(layer)
    }
    
    private func removeBoundingBox() {
        if let layer = layer {
            layer.removeFromSuperlayer()
        }
    }
}

class PreviewView: UIView {
    
    lazy var scanArea: CAShapeLayer = {
        let scanArea = CAShapeLayer()
        let largeRectpath = UIBezierPath(roundedRect: CGRect(x:self.bounds.origin.x, y: self.bounds.origin.y, width: self.bounds.width, height: self.bounds.height), cornerRadius: 0)
        
        let smallRectpath = UIBezierPath(roundedRect: CGRect(x: self.bounds.width/2 - 150, y: self.bounds.height/2 - 100, width: 300, height: 200), cornerRadius: 20)
        largeRectpath.append(smallRectpath)
        largeRectpath.usesEvenOddFillRule = true
        scanArea.path = largeRectpath.cgPath
        scanArea.fillRule = .evenOdd
        scanArea.fillColor = UIColor.darkGray.withAlphaComponent(0.75).cgColor
        scanArea.opacity = 0.5
        
        let myLayer = CALayer()
        let myImage = UIImage(named: "backward")?.cgImage
        myLayer.frame = CGRect(x: self.bounds.width/2 - 140, y: self.bounds.height/2-12
                               , width: 24, height: 24)
        myLayer.contents = myImage
        scanArea.addSublayer(myLayer)
       return scanArea
        
    }()
    
    override func layoutSubviews() {
        scanArea.removeFromSuperlayer()
        videoPreviewLayer.insertSublayer(scanArea, at: 1)
    }
    

    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        let customlayer:AVCaptureVideoPreviewLayer = layer as! AVCaptureVideoPreviewLayer
        return customlayer
    }
}







