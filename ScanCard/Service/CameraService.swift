//
//  CameraService.swift
//  ScanCard
//
//  Created by admin on 14/04/2021.
//

import AVFoundation
class CameraService {

    let presentViewController: ScanViewController!
    lazy var session: AVCaptureSession = {
        let session = AVCaptureSession()
        return session
    }()

    init(viewcontroller: ScanViewController) {
        self.presentViewController = viewcontroller
        self.setUpSession()
    }

    private func setUpInPut() {
        // Scan camera in device
        guard let device = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTrueDepthCamera,
                                                                          .builtInDualCamera,
                                                                          .builtInWideAngleCamera],
                                                            mediaType: .video,
                                                            position: .back).devices.first else {return}

        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: device), session.canAddInput(videoDeviceInput)
        else {return}
        session.addInput(videoDeviceInput)
    }

    private func setUpOutPut() {
        let myVideoOutput = AVCaptureVideoDataOutput()

        myVideoOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString)
                                        : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String: Any]
        guard session.canAddOutput(myVideoOutput) else {return}
        myVideoOutput.alwaysDiscardsLateVideoFrames = true
        myVideoOutput.setSampleBufferDelegate(presentViewController,
                                              queue: DispatchQueue.init(label: "Hanle recive videoFrame"))
        session.addOutput(myVideoOutput)

        guard let connection = myVideoOutput.connection(with: .video), connection.isVideoMirroringSupported
        else {return}
        connection.videoOrientation = .portrait

    }

    private func setUpSession() {
        session.beginConfiguration()
        setUpInPut()
        setUpOutPut()
        session.commitConfiguration()
    }

    public func startConnectCamera() {
        if !session.isRunning {
            session.startRunning()
        }
    }

    public func stopConnectCamera() {
        session.stopRunning()
    }

}
