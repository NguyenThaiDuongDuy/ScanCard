//
//  ViewController.swift
//  ScanCard
//
//  Created by admin on 05/04/2021.
//

import UIKit
import AVKit
import Vision

class ScanCardViewController: UIViewController {

    static let minimumAspectRatioCard = VNAspectRatio(1.3)
    static let maximumAspectRatioCard = VNAspectRatio(1.6)
    static let maximum1TimeCardDetect = 1
    static let minimumSizeDetectCard = Float(0.5)

    @IBOutlet weak var livePreviewView: PreviewView!
    @IBOutlet weak var scanButton: BlueStyleButton!
    @IBOutlet weak var shadowView: ShadowView!

    var scanTitleOfButton = "Scan"
    var scanTitle = "Scan Card"
    var layer: CALayer?
    var vnRectangleObservation: VNRectangleObservation?
    var sampleBuffer: CMSampleBuffer?
    var recognizedStrings: [String]?

    lazy var cameraService: CameraService = {
        let mCameraService = CameraService(viewController: self)
        return mCameraService
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpScanButton()
        setUpNavigationController()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupLiveView()
    }

    private func setupLiveView() {
        livePreviewView.videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        livePreviewView.videoPreviewLayer.cornerRadius = 30
        livePreviewView.videoPreviewLayer.masksToBounds = true
        livePreviewView.frame = shadowView.frame
        let tapAction = UITapGestureRecognizer(target: self, action: #selector(tap))
        livePreviewView.addGestureRecognizer(tapAction)
    }

    func setUpNavigationController() {
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
            self.getCardInformation(ciImage: result)
            self.dismiss(animated: true) {
                self.cameraService.stopConnectCamera()
                let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                if let scanTextViewController: ScanTextViewController =
                    mainStoryboard.instantiateViewController(withIdentifier: "ScanTextViewController")
                    as? ScanTextViewController {
                    scanTextViewController.cardImage = UIImage(ciImage: result)
                    scanTextViewController.scanTextViewModel = self.getInfoCardAuto(information: self.recognizedStrings)
                    self.navigationController?.pushViewController(scanTextViewController,
                                                                  animated: true)} else { return }
            }
        }
    }

    func setUpScanButton() {
        scanButton.setTitle(scanTitleOfButton, for: .normal)
    }

    @IBAction func tapScanButton(_ sender: Any) {
        livePreviewView.videoPreviewLayer.session = cameraService.session
        cameraService.startConnectCamera()
        self.requestUsingCamera { (_) in
        }
    }

    func requestUsingCamera(completion: (AVAuthorizationStatus) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // The user has previously granted access to the camera.
            completion(.authorized)
        case .notDetermined: // The user has not yet been asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    print("User granted")
                } else {
                    print("User not granted")
                }
            }
        case .denied: // The user has previously denied access.
            // Show dialog
            completion(.denied)
            print("User denied")
            return
        case .restricted: // The user can't grant access due to restrictions.
            completion(.restricted)
            print("User restricted")
            return
        @unknown default:
            print("Something came up")
        }
    }
}

extension ScanCardViewController: AVCaptureVideoDataOutputSampleBufferDelegate {

    func detectCard(sampleBuffer: CMSampleBuffer) {
        func detectRectanglesCompletionHandler (request: VNRequest, error: Error?) {
            DispatchQueue.main.async {
                // Request fail
                if let error = error {
                    print(error)
                    return
                }
                self.removeBoundingBox()
                guard let results = request.results as? [VNRectangleObservation] else { return }
                guard let vnRectangleObservation = results.first else { return }

                self.vnRectangleObservation = vnRectangleObservation
                self.sampleBuffer = sampleBuffer
                let convertUIKitRect = VNImageRectForNormalizedRect(vnRectangleObservation.boundingBox,
                                                                    (Int)(self.livePreviewView.bounds.width),
                                                                    (Int)(self.livePreviewView.bounds.height))
                self.drawBoundingBox(rect: convertUIKitRect)
            }
        }

        let request = VNDetectRectanglesRequest(completionHandler: detectRectanglesCompletionHandler)
        request.minimumAspectRatio = ScanCardViewController.minimumAspectRatioCard
        request.maximumAspectRatio = ScanCardViewController.maximumAspectRatioCard
        request.minimumSize = ScanCardViewController.minimumSizeDetectCard
        request.maximumObservations = ScanCardViewController.maximum1TimeCardDetect

        let requestHandler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, options: [:])

        try? requestHandler.perform([request])
    }

    func getCardInformation(ciImage: CIImage) {
        let request = VNRecognizeTextRequest { (request, _) in
            guard let observations =
                    request.results as? [VNRecognizedTextObservation] else {
                return
            }

            let recognizedStrings = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }

            self.recognizedStrings = recognizedStrings
            Logger.log(self.recognizedStrings as Any)
        }
        request.recognitionLevel = .accurate
        request.minimumTextHeight = 1 / 20
        let requestTextHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        try? requestTextHandler.perform([request])
    }

    func getInfoCardAuto(information: [String]?) -> ScanTextViewModel {
        let scanTextViewModel = ScanTextViewModel(cardInfo: Card(cardHolder: "",
                                                                 cardNumber: "",
                                                                 issueDate: "",
                                                                 expiryDate: ""))
        guard let checkInformation = information else { return scanTextViewModel }

        for index in stride(from: checkInformation.count - 1, to: 0, by: -1) {
            if scanTextViewModel.isValidCardHolder(cardHolder: checkInformation[index]) &&
                (((scanTextViewModel.cardModel?.cardHolder!.isEmpty)!)) {
                scanTextViewModel.cardModel?.cardHolder = checkInformation[index]
            }
            if scanTextViewModel.isValidCardNumber(cardNumber: checkInformation[index])
                && ((scanTextViewModel.cardModel?.cardNumber?.isEmpty)!) {
                scanTextViewModel.cardModel?.cardNumber = checkInformation[index]
            }

            if scanTextViewModel.isValidIssueDate(checkIssueDate: checkInformation[index])
                && ((scanTextViewModel.cardModel?.issueDate?.isEmpty)!) {
                scanTextViewModel.cardModel?.issueDate = checkInformation[index]
            }

            if scanTextViewModel.isValidExpiryDate(checkExpiryDate: checkInformation[index])
                && ((scanTextViewModel.cardModel?.expiryDate?.isEmpty)!) {
                scanTextViewModel.cardModel?.expiryDate = checkInformation[index]
            }
        }
        return scanTextViewModel
    }

    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        detectCard(sampleBuffer: sampleBuffer)
    }

    // Crop image in boundingbox
    private func extractPerspectiveRect(_ observation: VNRectangleObservation, from buffer: CVImageBuffer) -> CIImage {
        // get the pixel buffer into Core Image
        let ciImage = CIImage(cvImageBuffer: buffer)

        // convert corners from normalized image coordinates to pixel coordinates
        let topLeft = observation.topLeft.convertToPixelCoordinate(to: ciImage.extent.size)
        let topRight = observation.topRight.convertToPixelCoordinate(to: ciImage.extent.size)
        let bottomLeft = observation.bottomLeft.convertToPixelCoordinate(to: ciImage.extent.size)
        let bottomRight = observation.bottomRight.convertToPixelCoordinate(to: ciImage.extent.size)

        // pass those to the filter to extract/rectify the image
        return ciImage.applyingFilter("CIPerspectiveCorrection", parameters: [
            "inputTopLeft": CIVector(cgPoint: topLeft),
            "inputTopRight": CIVector(cgPoint: topRight),
            "inputBottomLeft": CIVector(cgPoint: bottomLeft),
            "inputBottomRight": CIVector(cgPoint: bottomRight)
        ])
    }

    private func drawBoundingBox(rect: CGRect) {
        layer = CAShapeLayer()
        layer?.frame = rect
        layer?.cornerRadius = 10
        layer?.opacity = 0.75
        layer?.borderColor = UIColor.red.cgColor
        layer?.borderWidth = 5.0
        livePreviewView.layer.addSublayer(layer ?? CAShapeLayer())
    }

    private func removeBoundingBox() {
        if let layer = layer {
            layer.removeFromSuperlayer()
        }
    }
}
