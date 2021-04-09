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
    
    static let scanString = "Scan"
    static let minCommonCardWidth:CGFloat = 333.0
    static let maxCommonCardWidth:CGFloat = 345.0
    
    var layer:CALayer!
    var mVNRectangleObservation: VNRectangleObservation?
    var mSampleBuffer:CMSampleBuffer?
    var mRecognizedStrings:[String]?
    
   
    
    lazy var mCameraService:CameraService = {
        let mCameraService = CameraService(viewcontroller: self)
        return mCameraService
    }()
    
    @IBOutlet weak var liveVideoView: PreviewView!
    @IBOutlet weak var scanButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = . white
        
        let tapAction = UITapGestureRecognizer(target: self, action: #selector(tap))
        self.liveVideoView.addGestureRecognizer(tapAction)
        setUpScanButton()
    }
    
    @objc func tap() {
        DispatchQueue.main.async {
            print("tap")
            self.mCameraService.session.stopRunning()
            guard let mVNRectangleObservation = self.mVNRectangleObservation,let mSampleBuffer = self.mSampleBuffer else  {return}
            let result =  self.extractPerspectiveRect(mVNRectangleObservation, from: mSampleBuffer.imageBuffer!)
            self.getCardInformation(ciimage: result)
            self.dismiss(animated: true) {
                self.mCameraService.session.stopRunning()
                let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                let vc : InformationViewcontroller = mainStoryboard.instantiateViewController(withIdentifier: "InformationViewcontroller") as! InformationViewcontroller
                vc.cardImage = UIImage(ciImage: result)
                vc.mRecognizedStrings = self.mRecognizedStrings
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func setUpScanButton() {
        scanButton.backgroundColor = .blue
        scanButton.setTitle(ScanViewController.scanString, for: .normal)
        scanButton.tintColor = .white
        scanButton.layer.cornerRadius = scanButton.bounds.height/2
    }
    
    @IBAction func tapScanButton(_ sender: Any) {
        
        liveVideoView.videoPreviewLayer.session = mCameraService.session
        mCameraService.startCamera()
        
        AuthorService.share.reQuestUsingCamera { (author) in
        }
    }
    
}

class CameraService {
    
    let presentViewController:ScanViewController!
    lazy var session:AVCaptureSession = {
        let session = AVCaptureSession()
        return session
    }()
    
    
    init(viewcontroller:ScanViewController){
        self.presentViewController = viewcontroller
        self.setUpSession()
    }
    
    private func setUpInPut(){
        //Scan camera in device
        guard let device = AVCaptureDevice.DiscoverySession(deviceTypes:
                                                                [.builtInTrueDepthCamera, .builtInDualCamera, .builtInWideAngleCamera],
                                                            mediaType: .video,
                                                            position: .back).devices.first else {return}
        //
        
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: device), session.canAddInput(videoDeviceInput)
        else {return}
        
        session.addInput(videoDeviceInput)
        
    }
    
    private func setUpOutPut() {
        let myVideoOutput = AVCaptureVideoDataOutput()
        
        myVideoOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
        guard session.canAddOutput(myVideoOutput) else {return}
        myVideoOutput.alwaysDiscardsLateVideoFrames = true
        myVideoOutput.setSampleBufferDelegate(presentViewController, queue: DispatchQueue.init(label: "Hanle recive videoFrame"))
        session.addOutput(myVideoOutput)
        
        guard let connection = myVideoOutput.connection(with: .video), connection.isVideoMirroringSupported else {return}
        connection.videoOrientation = .portrait
        
    }
    
    private func setUpSession() {
        session.beginConfiguration()
        setUpInPut()
        setUpOutPut()
        session.commitConfiguration()
    }
    
    public func startCamera() {
        session.startRunning()
    }
    
    private func stopCamera() {
        
    }
    
}

extension ScanViewController:AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func detecCard(sampleBuffer: CMSampleBuffer) {
        func detectRectanglesCompletionHandler (request: VNRequest, error: Error?) {
            DispatchQueue.main.async {
                //Request fail
                if let _ = error {
                    //print error
                    return
                }
                
                if let layer = self.layer {
                    layer.removeFromSuperlayer()
                }
                
                guard let results = request.results as? [VNRectangleObservation] else { return }
                
                //self.removeMask()
                
                
                guard let rect = results.first else {return}
                
                self.mVNRectangleObservation = rect
                self.mSampleBuffer = sampleBuffer
                
                
                let mrec = VNImageRectForNormalizedRect(rect.boundingBox,
                                                        (Int)(self.liveVideoView.bounds.width),
                                                        (Int)(self.liveVideoView.bounds.height))
                
                self.drawBoundingBox(rec: mrec)
            }
        }
        
        let request = VNDetectRectanglesRequest(completionHandler:detectRectanglesCompletionHandler)
        request.minimumAspectRatio = VNAspectRatio(1.3)
        request.maximumAspectRatio = VNAspectRatio(1.6)
        request.minimumSize = Float(0.5)
        request.maximumObservations = 1
        
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
                // Return the string of the top VNRecognizedText instance.
                return observation.topCandidates(1).first?.string
            }
            
            self.mRecognizedStrings = recognizedStrings
            print(recognizedStrings)
        }
        request.recognitionLevel = .accurate
        
        
        //let rotateImage = ciimage.oriented(.right)
        let requestTextHandler = VNImageRequestHandler(ciImage: ciimage, options: [:])
        try? requestTextHandler.perform([request])
    }
    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        self.detecCard(sampleBuffer: sampleBuffer)
    }
    
    
    //Crop image in boundingbox
    func extractPerspectiveRect(_ observation: VNRectangleObservation, from buffer: CVImageBuffer) -> CIImage {
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
    
    func drawBoundingBox(rec:CGRect) {
        layer = CAShapeLayer()
        layer.frame = rec
        layer.cornerRadius = 10
        layer.opacity = 0.75
        layer.borderColor = UIColor.red.cgColor
        layer.borderWidth = 5.0
        self.liveVideoView.layer.addSublayer(layer)
    }
}

class PreviewView: UIView {
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    /// Convenience wrapper to get layer as its statically known type.
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
}

extension CGPoint {
    func scaled(to size: CGSize) -> CGPoint {
        return CGPoint(x: self.x * size.width,
                       y: self.y * size.height)
    }
}





