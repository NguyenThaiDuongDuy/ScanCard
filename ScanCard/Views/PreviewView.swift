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

    lazy var scanArea: CAShapeLayer = {
        let scanArea = CAShapeLayer()
        let largeRectpath = UIBezierPath(roundedRect: CGRect(x: self.bounds.origin.x,
                                                             y: self.bounds.origin.y,
                                                             width: self.bounds.width,
                                                             height: self.bounds.height), cornerRadius: 0)

        let smallRectpath = UIBezierPath(roundedRect: CGRect(x: self.bounds.width / 2 - 150,
                                                             y: self.bounds.height / 2 - 100,
                                                             width: 300,
                                                             height: 200),
                                                             cornerRadius: 20)
        largeRectpath.append(smallRectpath)
        largeRectpath.usesEvenOddFillRule = true
        scanArea.path = largeRectpath.cgPath
        scanArea.fillRule = .evenOdd
        scanArea.fillColor = UIColor.darkGray.withAlphaComponent(0.75).cgColor
        scanArea.opacity = 0.5

        let myLayer = CALayer()
        let myImage = UIImage(named: "backward")?.cgImage
        myLayer.frame = CGRect(x: self.bounds.width / 2 - 140,
                               y: self.bounds.height / 2 - 12,
                               width: 24,
                               height: 24)
        myLayer.contents = myImage
        scanArea.addSublayer(myLayer)
       return scanArea
    }()

    override func layoutSubviews() {
        scanArea.removeFromSuperlayer()
        videoPreviewLayer.insertSublayer(scanArea, at: 1)
    }

    override class var layerClass: AnyClass {
    AVCaptureVideoPreviewLayer.self
    }

    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        if let customlayer: AVCaptureVideoPreviewLayer = layer as? AVCaptureVideoPreviewLayer {
            return customlayer } else {
            return AVCaptureVideoPreviewLayer()
        }
    }
}
