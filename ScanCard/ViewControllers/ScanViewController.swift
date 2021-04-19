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

    static let minCommonCardWidth: CGFloat = 333.0
    static let maxCommonCardWidth: CGFloat = 345.0
    static let minimumAspectRatioCard = VNAspectRatio(1.3)
    static let maximumAspectRatioCard = VNAspectRatio(1.6)
    static let maximum1TimeCardDetect = 1
    static let miniSizeDetectCard = Float(0.5)

    @IBOutlet weak var liveVideoView: PreviewView!
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var shadowView: PreviewView!

    var scanString = "Scan"
    var scanTitle = "Scan Card"
    var layer: CALayer?
    var vnRectangleObservation: VNRectangleObservation?
    var sampleBuffer: CMSampleBuffer?
    var recognizedStrings: [String]?

    lazy var cameraService: CameraService = {
        let mCameraService = CameraService(viewcontroller: self)
        return mCameraService
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = . white

        let tapAction = UITapGestureRecognizer(target: self, action: #selector(tap))
        self.liveVideoView.addGestureRecognizer(tapAction)
        setUpScanButton()
        setUpNavi()
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

    func setUpNavi() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(),
                                                               for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        title = scanTitle
    }

    @objc func tap() {
        DispatchQueue.main.async {
            self.cameraService.session.stopRunning()
            guard let mVNRectangleObservation = self.vnRectangleObservation,
                  let mSampleBuffer = self.sampleBuffer else { return }
            guard let imageBuffer = mSampleBuffer.imageBuffer else { return }
            let result = self.extractPerspectiveRect(mVNRectangleObservation, from: imageBuffer)
            self.getCardInformation(ciimage: result)
            self.dismiss(animated: true) {
                self.cameraService.stopConnectCamera()
                let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                if let scanTextViewController: ScanTextViewController =
                    mainStoryboard.instantiateViewController(withIdentifier: "ScanTextViewController")
                    as? ScanTextViewController {
                    scanTextViewController.cardImage = UIImage(ciImage: result)
                    scanTextViewController.scanTextViewModel = self.getInfoCardAuto(infomation: self.recognizedStrings)
                    self.navigationController?.pushViewController(scanTextViewController,
                                                                  animated: true)} else { return }
            }
        }
    }

    func setUpScanButton() {
        scanButton.setTitle(scanString, for: .normal)
        scanButton.applyStyle()
    }

    @IBAction func tapScanButton(_ sender: Any) {
        liveVideoView.videoPreviewLayer.session = cameraService.session
        cameraService.startConnectCamera()
        AuthorService.share.reQuestUsingCamera { (_) in
        }
    }
}

extension ScanViewController: AVCaptureVideoDataOutputSampleBufferDelegate {

    func detecCard(sampleBuffer: CMSampleBuffer) {
        func detectRectanglesCompletionHandler (request: VNRequest, error: Error?) {
            DispatchQueue.main.async {
                // Request fail
                if let error = error {
                    print(error)
                    return
                }
                self.removeBoundingBox()
                guard let results = request.results as? [VNRectangleObservation] else { return }
                guard let rect = results.first else { return }

                self.vnRectangleObservation = rect
                self.sampleBuffer = sampleBuffer
                let convertUIKitrect = VNImageRectForNormalizedRect(rect.boundingBox,
                                                                    (Int)(self.liveVideoView.bounds.width),
                                                                    (Int)(self.liveVideoView.bounds.height))
                self.drawBoundingBox(rec: convertUIKitrect)
            }
        }

        let request = VNDetectRectanglesRequest(completionHandler: detectRectanglesCompletionHandler)
        request.minimumAspectRatio = ScanViewController.minimumAspectRatioCard
        request.maximumAspectRatio = ScanViewController.maximumAspectRatioCard
        request.minimumSize = ScanViewController.miniSizeDetectCard
        request.maximumObservations = ScanViewController.maximum1TimeCardDetect

        let requestHandler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, options: [:])

        try? requestHandler.perform([request])
    }

    func getCardInformation(ciimage: CIImage) {
        let request = VNRecognizeTextRequest { (request, _) in
            guard let observations =
                    request.results as? [VNRecognizedTextObservation] else {
                return
            }

            let recognizedStrings = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }

            self.recognizedStrings = recognizedStrings
            print(recognizedStrings.description)
        }
        request.recognitionLevel = .accurate
        request.minimumTextHeight = 1 / 20
        let requestTextHandler = VNImageRequestHandler(ciImage: ciimage, options: [:])
        try? requestTextHandler.perform([request])
    }

    func getInfoCardAuto(infomation: [String]?) -> ScanTextViewModel {
        let scanTextViewModel = ScanTextViewModel(userInfor: UserInfoModel(name: "",
                                                                           bankNumber: "",
                                                                           createdDate: "",
                                                                           validDate: ""))
        guard let checkInfomation = infomation else { return scanTextViewModel }

        for index in stride(from: checkInfomation.count - 1, to: 0, by: -1) {
            if scanTextViewModel.isValidName(name: checkInfomation[index]) &&
                (((scanTextViewModel.userInfo?.name!.isEmpty)!)) {
                scanTextViewModel.userInfo?.name = checkInfomation[index]
            }
            if scanTextViewModel.isValidNumberBank(banknumber: checkInfomation[index])
                && ((scanTextViewModel.userInfo?.bankNumber?.isEmpty)!) {
                scanTextViewModel.userInfo?.bankNumber = checkInfomation[index]
            }

            if scanTextViewModel.isValidCreatedDate(checkDate: checkInfomation[index])
                && ((scanTextViewModel.userInfo?.createdDate?.isEmpty)!) {
                scanTextViewModel.userInfo?.createdDate = checkInfomation[index]
            }

            if scanTextViewModel.isValidValidateDate(checkDate: checkInfomation[index])
                && ((scanTextViewModel.userInfo?.validDate?.isEmpty)!) {
                scanTextViewModel.userInfo?.validDate = checkInfomation[index]
            }
        }
        return scanTextViewModel
    }

    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        detecCard(sampleBuffer: sampleBuffer)
    }

    // Crop image in boundingbox
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
            "inputBottomRight": CIVector(cgPoint: bottomRight)
        ])
    }

    func captureOutput(_ output: AVCaptureOutput,
                       didDrop sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        print("captureOutput didDorp")
    }

    private func drawBoundingBox(rec: CGRect) {
        layer = CAShapeLayer()
        layer?.frame = rec
        layer?.cornerRadius = 10
        layer?.opacity = 0.75
        layer?.borderColor = UIColor.red.cgColor
        layer?.borderWidth = 5.0
        liveVideoView.layer.addSublayer(layer ?? CAShapeLayer())
    }

    private func removeBoundingBox() {
        if let layer = layer {
            layer.removeFromSuperlayer()
        }
    }
}
