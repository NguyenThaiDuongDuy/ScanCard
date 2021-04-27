//
//  PreviewView.swift
//  
//
//  Created by admin on 15/04/2021.
//

import Foundation
import UIKit
import AVFoundation

class PreviewView: UIView {

    lazy var scanAreaShapeLayer: CAShapeLayer = {
        let scanArea = CAShapeLayer()
        let largeRectanglePath = UIBezierPath(roundedRect: CGRect(x: self.bounds.origin.x,
                                                                  y: self.bounds.origin.y,
                                                                  width: self.bounds.width,
                                                                  height: self.bounds.height),
                                              cornerRadius: 0)

        let smallRectanglePath = UIBezierPath(roundedRect: CGRect(x: self.bounds.width / 2 - 150,
                                                                  y: self.bounds.height / 2 - 100,
                                                                  width: 300,
                                                                  height: 200),
                                              cornerRadius: 20)
        largeRectanglePath.append(smallRectanglePath)
        largeRectanglePath.usesEvenOddFillRule = true
        scanArea.path = largeRectanglePath.cgPath
        scanArea.fillRule = .evenOdd
        scanArea.fillColor = UIColor.darkGray.withAlphaComponent(0.75).cgColor
        scanArea.opacity = 0.5

        let layerArrow = CALayer()
        let arrowImage = UIImage(named: "backward")?.cgImage
        layerArrow.frame = CGRect(x: self.bounds.width / 2 - 140,
                                  y: self.bounds.height / 2 - 12,
                                  width: 24,
                                  height: 24)
        layerArrow.contents = arrowImage
        scanArea.addSublayer(layerArrow)
        return scanArea
    }()

    override func layoutSubviews() {
        super.layoutSubviews()
        scanAreaShapeLayer.removeFromSuperlayer()
        videoPreviewLayer.insertSublayer(scanAreaShapeLayer, at: 1)
    }

    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        if let avLayer: AVCaptureVideoPreviewLayer = layer as? AVCaptureVideoPreviewLayer {
            return avLayer } else {
                return AVCaptureVideoPreviewLayer()
            }
    }
}
