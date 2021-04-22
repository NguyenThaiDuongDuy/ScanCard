import AVKit
import UIKit
import Vision

class ScanCardViewController: UIViewController {

    static let minimumAspectRatioCard = VNAspectRatio(1.3)
    static let maximumAspectRatioCard = VNAspectRatio(1.6)
    static let maximum1TimeCardDetect = 1
    static let minimumSizeDetectCard = Float(0.5)
    static let scanTitleOfButton = "Scan"
    static let scanTitleOfNavigation = "Scan Card"

    @IBOutlet weak var liveVideoView: PreviewView!
    @IBOutlet weak var scanButton: BlueStyleButton!
    @IBOutlet weak var shadowView: ShadowView!

    var layer: CALayer?
    var rectangleDetectFromVisionService: VNRectangleObservation?
    var videoFrame: CMSampleBuffer?
    var recognizedStrings: [String]?

    lazy var service: CameraService = {
        let service = CameraService(viewController: self)
        return service
    }()

    init() {
        super.init(nibName: String(describing: type(of: self)), bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpScanButton()
        setUpNavigationController()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setUpLiveView()
    }

    private func setUpLiveView() {
        liveVideoView.videoPreviewLayer.videoGravity = .resizeAspectFill
        liveVideoView.videoPreviewLayer.cornerRadius = 30
        liveVideoView.videoPreviewLayer.masksToBounds = true
        liveVideoView.translatesAutoresizingMaskIntoConstraints = false
        let tapAction = UITapGestureRecognizer(target: self, action: #selector(tapLiveVideoView))
        liveVideoView.addGestureRecognizer(tapAction)
    }

    func setUpNavigationController() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(),
                                                               for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        title = ScanCardViewController.scanTitleOfNavigation
    }

    @objc func tapLiveVideoView() {
            self.service.session.stopRunning()
            guard let rectangleDetectFromVisionService = self.rectangleDetectFromVisionService,
                  let videoFrame = self.videoFrame else { return }
            guard let imageBuffer = videoFrame.imageBuffer else { return }
            let cropFrame = self.extractPerspectiveRect(rectangleDetectFromVisionService, from: imageBuffer)
            self.getCardInformation(cropFrame: cropFrame)
            self.dismiss(animated: true) {
                self.service.stopConnectCamera()
                let scanTextView = ScanTextViewController(cardImage: UIImage(ciImage: cropFrame),
                                                          informationCard: self.recognizedStrings)
                self.navigationController?.pushViewController(scanTextView, animated: true)
            }
    }

    func setUpScanButton() {
        scanButton.setTitle(ScanCardViewController.scanTitleOfButton, for: .normal)
    }

    @IBAction func tapScanButton(_ sender: Any) {
        liveVideoView.videoPreviewLayer.session = service.session
        service.startConnectCamera()
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

    func detectCard(videoFrame: CMSampleBuffer) {
        func detectRectanglesCompletionHandler (request: VNRequest, error: Error?) {
            DispatchQueue.main.async {
                // Request fail
                if let error = error {
                    print(error)
                    return
                }
                self.removeBoundingBox()
                guard let rectanglesDetectFromVisionService = request.results as?
                        [VNRectangleObservation] else { return }
                guard let rectangleDetectFromVisionService = rectanglesDetectFromVisionService.first else { return }

                self.rectangleDetectFromVisionService = rectangleDetectFromVisionService
                self.videoFrame = videoFrame
                let convertUIKitRect = VNImageRectForNormalizedRect(rectangleDetectFromVisionService.boundingBox,
                                                                    (Int)(self.liveVideoView.bounds.width),
                                                                    (Int)(self.liveVideoView.bounds.height))
                self.drawBoundingBox(rect: convertUIKitRect)
            }
        }

        let request = VNDetectRectanglesRequest(completionHandler: detectRectanglesCompletionHandler)
        request.minimumAspectRatio = ScanCardViewController.minimumAspectRatioCard
        request.maximumAspectRatio = ScanCardViewController.maximumAspectRatioCard
        request.minimumSize = ScanCardViewController.minimumSizeDetectCard
        request.maximumObservations = ScanCardViewController.maximum1TimeCardDetect

        let requestHandler = VNImageRequestHandler(cmSampleBuffer: videoFrame, options: [:])

        try? requestHandler.perform([request])
    }

    func getCardInformation(cropFrame: CIImage) {
        let request = VNRecognizeTextRequest { (request, _) in
            guard let textObservations =
                    request.results as? [VNRecognizedTextObservation] else {
                return
            }

            let recognizedStrings = textObservations.compactMap { textObservation in
                textObservation.topCandidates(1).first?.string
            }

            self.recognizedStrings = recognizedStrings
            Logger.log(self.recognizedStrings as Any)
        }
        request.recognitionLevel = .accurate
        request.minimumTextHeight = 1 / 20
        let requestTextHandler = VNImageRequestHandler(ciImage: cropFrame, options: [:])
        try? requestTextHandler.perform([request])
    }

    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        detectCard(videoFrame: sampleBuffer)
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
        liveVideoView.layer.addSublayer(layer ?? CAShapeLayer())
    }

    private func removeBoundingBox() {
        if let layer = layer {
            layer.removeFromSuperlayer()
        }
    }
}
