import AVKit
import UIKit
import Vision

class ScanCardViewController: UIViewController {

    private let scanButtonTitle = "Scan"
    private let scanNavigationTitle = "Scan Card"
    private let languages = ["En", "Vn"]
    private let numberOfComponent = 1

    @IBOutlet weak var liveVideoView: PreviewView!
    @IBOutlet weak var scanButton: BlueStyleButton!
    @IBOutlet weak var shadowView: ShadowView!
    @IBOutlet weak var languagePickerView: UIPickerView!

    private var boundingBoxLayer: CALayer?
    private var cardRectangleObservation: VNRectangleObservation?
    private var sampleBuffer: CMSampleBuffer?
    private var recognizedStrings: [String]?

    private lazy var service: CameraService = {
        let service = CameraService(viewController: self)
        return service
    }()

    public init() {
        super.init(nibName: String(describing: type(of: self)), bundle: Bundle(for: type(of: self)))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        languagePickerView.delegate = self
        languagePickerView.dataSource = self
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
        guard let cardRectangleObservation = self.cardRectangleObservation,
              let sampleBuffer = self.sampleBuffer else { return }
        guard let imageBuffer = sampleBuffer.imageBuffer else { return }
        let cropFrame = extractPerspectiveRect(cardRectangleObservation, from: imageBuffer)
        dismiss(animated: true) {
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
        requestUsingCamera { (canUse) in
            if canUse {
                DispatchQueue.main.async {
                    self.liveVideoView.videoPreviewLayer.session = self.service.session
                    self.service.startConnectCamera()
                }
            }
        }
    }

    func requestUsingCamera(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // The user has previously granted access to the camera.
            Logger.log("User authorized")
            completion(true)

        case .notDetermined: // The user has not yet been asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    Logger.log("User granted")
                    completion(true)
                } else {
                    Logger.log("User not granted")
                    completion(false)
                }
            }

        case .denied: // The user has previously denied access.
            // Show dialog
            completion(false)
            Logger.log("User denied")

        case .restricted: // The user can't grant access due to restrictions.
            completion(false)
            Logger.log("User restricted")

        @unknown default:
            completion(false)
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
                    self.sampleBuffer = sampleBuffer
                    self.cardRectangleObservation = rectangle

                case .failure(let error):
                    Logger.log(error.localizedDescription)
                }
            }
        }
    }

    // Crop image in bounding box
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
                                                            (Int)(liveVideoView.bounds.width),
                                                            (Int)(liveVideoView.bounds.height))
        boundingBoxLayer = CAShapeLayer()
        boundingBoxLayer?.frame = convertUIKitRect
        boundingBoxLayer?.cornerRadius = 10
        boundingBoxLayer?.opacity = 0.75
        boundingBoxLayer?.borderColor = UIColor.red.cgColor
        boundingBoxLayer?.borderWidth = 5.0
        liveVideoView.layer.addSublayer(boundingBoxLayer ?? CAShapeLayer())
    }

    private func removeBoundingBox() {
        boundingBoxLayer?.removeFromSuperlayer()
    }
}

extension ScanCardViewController: UIPickerViewDataSource, UIPickerViewDelegate {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        numberOfComponent
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
