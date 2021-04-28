import AVKit
import UIKit
import Vision

enum ModeScan {
    case all
    case cardHolder
    case cardNumBer
    case issueDate
    case expiryDate
}

class ScanCardViewController: UIViewController {

    private let scanButtonTitle = "Scan"
    private let scanNavigationTitle = "Scan Card"
    private let languages = ["En", "Vn"]
    private let numberOfComponentInLanguageChosenView = 1
    var modeScan: ModeScan?

    @IBOutlet weak var liveVideoView: PreviewView!
    @IBOutlet weak var scanButton: BlueStyleButton!
    @IBOutlet weak var shadowView: ShadowView!
    @IBOutlet weak var languageChosenView: UIPickerView!

    private var layerBoundingBox: CALayer?
    private var rectangleDetect: VNRectangleObservation?
    private var videoFrame: CMSampleBuffer?
    private var recognizedStrings: [String]?

    private lazy var service: CameraService = {
        let service = CameraService(viewController: self)
        return service
    }()

    init(modeScan: ModeScan = .all) {
        super.init(nibName: String(describing: type(of: self)), bundle: nil)
        self.modeScan = modeScan
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setLanguageForView()
        setUpNavigationController()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setUpLiveView()
        setUpLanguageChosenView()
    }

    private func setUpLanguageChosenView() {
        languageChosenView.delegate = self
        languageChosenView.dataSource = self
    }

    private func setUpLiveView() {
        liveVideoView.videoPreviewLayer.videoGravity = .resizeAspectFill
        liveVideoView.videoPreviewLayer.cornerRadius = 30
        liveVideoView.videoPreviewLayer.masksToBounds = true
        liveVideoView.translatesAutoresizingMaskIntoConstraints = false
        let tapAction = UITapGestureRecognizer(target: self, action: #selector(tapLiveVideoView))
        liveVideoView.addGestureRecognizer(tapAction)
    }

    private func setUpNavigationController() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(),
                                                               for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }

    @objc func tapLiveVideoView() {
        service.session.stopRunning()
        guard let rectangleDetect = self.rectangleDetect,
              let videoFrame = self.videoFrame else { return }
        guard let imageBuffer = videoFrame.imageBuffer else { return }
        let cropFrame = self.extractPerspectiveRect(rectangleDetect, from: imageBuffer)
        self.dismiss(animated: true) {
            self.service.stopConnectCamera()
            let scanTextView = ScanTextViewController(cardImage: cropFrame)
            self.navigationController?.pushViewController(scanTextView, animated: true)
        }
    }

    private func setLanguageForView() {
        scanButton.setTitle(Language.share.localized(string: scanButtonTitle), for: .normal)
        title = Language.share.localized(string: scanNavigationTitle)
    }

    @IBAction func tapScanButton(_ sender: Any) {
        liveVideoView.videoPreviewLayer.session = service.session
        service.startConnectCamera()
        requestUsingCamera { (_) in
        }
    }

    func requestUsingCamera(completion: (AVAuthorizationStatus) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // The user has previously granted access to the camera.
            completion(.authorized)
        case .notDetermined: // The user has not yet been asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    Logger.log("User granted")
                } else {
                    Logger.log("User not granted")
                }
            }
        case .denied: // The user has previously denied access.
            // Show dialog
            completion(.denied)
            Logger.log("User denied")
            return
        case .restricted: // The user can't grant access due to restrictions.
            completion(.restricted)
            Logger.log("User restricted")
            return
        @unknown default:
            Logger.log("Something came up")
        }
    }
}

extension ScanCardViewController: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        DispatchQueue.main.async {
            self.removeBoundingBox()
            ImageDetector.detectCard(sampleBuffer: sampleBuffer) { resultOfDetectCard in
                switch resultOfDetectCard {
                case .success(let rectangle):
                    self.drawBoundingBox(rect: rectangle)
                    self.videoFrame = sampleBuffer
                    self.rectangleDetect = rectangle

                case .failure(let error):
                    Logger.log(error.localizedDescription)
                }
            }
        }
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

    private func drawBoundingBox(rect: VNRectangleObservation) {
        let convertUIKitRect = VNImageRectForNormalizedRect(rect.boundingBox,
                                                            (Int)(self.liveVideoView.bounds.width),
                                                            (Int)(self.liveVideoView.bounds.height))
        layerBoundingBox = CAShapeLayer()
        layerBoundingBox?.frame = convertUIKitRect
        layerBoundingBox?.cornerRadius = 10
        layerBoundingBox?.opacity = 0.75
        layerBoundingBox?.borderColor = UIColor.red.cgColor
        layerBoundingBox?.borderWidth = 5.0
        liveVideoView.layer.addSublayer(layerBoundingBox ?? CAShapeLayer())
    }

    private func removeBoundingBox() {
        layerBoundingBox?.removeFromSuperlayer()
    }
}

extension ScanCardViewController: UIPickerViewDataSource, UIPickerViewDelegate {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        numberOfComponentInLanguageChosenView
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        languages.count
    }

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int,
                    forComponent component: Int) -> NSAttributedString? {
        NSAttributedString(string: languages[row],
                           attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        Language.share.isEnglish = languages[row] == "En"
        setLanguageForView()
    }
}
