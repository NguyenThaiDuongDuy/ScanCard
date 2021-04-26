import AVKit
import UIKit
import Vision

class ScanCardViewController: UIViewController {

    static let minimumAspectRatioCard = VNAspectRatio(1.3)
    static let maximumAspectRatioCard = VNAspectRatio(1.6)
    static let maximum1TimeCardDetect = 1
    static let minimumSizeDetectCard = Float(0.5)
    let scanTitleOfButton = "Scan"
    let scanTitleOfNavigation = "Scan Card"
    let languages = ["En", "Vn"]
    let numberOfComponentInLanguageChosenView = 1

    @IBOutlet weak var liveVideoView: PreviewView!
    @IBOutlet weak var scanButton: BlueStyleButton!
    @IBOutlet weak var shadowView: ShadowView!
    @IBOutlet weak var languageChosenView: UIPickerView!

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

    func setUpNavigationController() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(),
                                                               for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }

    @objc func tapLiveVideoView() {
            self.service.session.stopRunning()
            guard let rectangleDetectFromVisionService = self.rectangleDetectFromVisionService,
                  let videoFrame = self.videoFrame else { return }
            guard let imageBuffer = videoFrame.imageBuffer else { return }
            let cropFrame = self.extractPerspectiveRect(rectangleDetectFromVisionService, from: imageBuffer)
            self.dismiss(animated: true) {
                self.service.stopConnectCamera()
                let scanTextView = ScanTextViewController(cardImage: cropFrame)
                self.navigationController?.pushViewController(scanTextView, animated: true)
            }
    }

    private func setLanguageForView() {
        scanButton.setTitle(Language.share.localized(string: scanTitleOfButton), for: .normal)
        title = Language.share.localized(string: scanTitleOfNavigation)
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

    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        DispatchQueue.main.async {
            self.removeBoundingBox()
            Detector.share.detectCard(videoFrame: sampleBuffer) { resultOfDetectCard in

                switch resultOfDetectCard {
                case .success(let rectangleFromVisionService):
                    self.drawBoundingBox(rectFromVisionService: rectangleFromVisionService)
                    self.videoFrame = sampleBuffer
                    self.rectangleDetectFromVisionService = rectangleFromVisionService

                case .failure(let error):
                    print(error.localizedDescription)
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

    private func drawBoundingBox(rectFromVisionService: VNRectangleObservation) {
        let convertUIKitRect = VNImageRectForNormalizedRect(rectFromVisionService.boundingBox,
                                                            (Int)(self.liveVideoView.bounds.width),
                                                            (Int)(self.liveVideoView.bounds.height))
        self.layer = CAShapeLayer()
        self.layer?.frame = convertUIKitRect
        self.layer?.cornerRadius = 10
        self.layer?.opacity = 0.75
        self.layer?.borderColor = UIColor.red.cgColor
        self.layer?.borderWidth = 5.0
        self.liveVideoView.layer.addSublayer(self.layer ?? CAShapeLayer())
    }

    private func removeBoundingBox() {
        layer?.removeFromSuperlayer()
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
