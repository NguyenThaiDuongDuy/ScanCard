//
//  CardView.swift
//  
//
//  Created by admin on 15/04/2021.
//

import Foundation
import UIKit

protocol CardViewDelegate: AnyObject {
    func getTextFromImage(textImage: CGImage, mode: ScanMode)
}

class CardImageView: UIImageView {

    weak var delegate: CardViewDelegate?
    private var scanMode: ScanMode = .cardHolder {
        didSet {
            let attributes = [
                NSAttributedString.Key.font: UIFont(name: "Chalkduster", size: 15.0)! ,
                NSAttributedString.Key.foregroundColor: UIColor.cyan
            ]
            let attributedString = NSAttributedString(string: Language.share.localized(string: scanMode.modeString),
                                                      attributes: attributes )
            titleTextLayer.string = attributedString
        }
    }

    private lazy var titleTextLayer: CATextLayer = {
        let titleTextLayer = CATextLayer()
        titleTextLayer.contentsScale = UIScreen.main.scale
        return titleTextLayer
    }()

    private lazy var scanAreaShapeLayer: CAShapeLayer = {
        let scanAreaShapeLayer = CAShapeLayer()
        scanAreaShapeLayer.borderColor = UIColor.white.cgColor
        scanAreaShapeLayer.borderWidth = 2.0
        scanAreaShapeLayer.fillColor = UIColor.white.withAlphaComponent(0.5).cgColor
        return scanAreaShapeLayer
    }()

    private var firstPoint: CGPoint = CGPoint.zero
    private var endPoint: CGPoint = CGPoint.zero
    private var boundingRect: CGRect?

    func setMode(scanMode: ScanMode) {
        self.scanMode = scanMode
    }

    private func drawScanRect(rect: CGRect) {

        scanAreaShapeLayer.path = UIBezierPath(roundedRect: rect, cornerRadius: 10).cgPath
        scanAreaShapeLayer.borderColor = UIColor.white.cgColor
        scanAreaShapeLayer.borderWidth = 2.0
        scanAreaShapeLayer.fillColor = UIColor.white.withAlphaComponent(0.5).cgColor

        let titleFrame = CGRect(x: rect.minX, y: rect.minY - 20, width: 200, height: 100)
        titleTextLayer.frame = titleFrame

        scanAreaShapeLayer.addSublayer(titleTextLayer)
        layer.addSublayer(scanAreaShapeLayer)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let touch = touches.first?.location(in: self)
        firstPoint = touch ?? CGPoint.zero
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        let touch = touches.first?.location(in: self)
        endPoint = touch ?? CGPoint.zero
        let rect = CGRect(x: min(firstPoint.x, endPoint.x),
                          y: min(firstPoint.y, endPoint.y),
                          width: abs(firstPoint.x - endPoint.x),
                          height: abs(firstPoint.y - endPoint.y))
        drawScanRect(rect: rect)
        boundingRect = rect
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        layer.sublayers?.removeAll()
        let snapshotImage = snapshot(of: boundingRect)
        guard let cgImage = snapshotImage?.cgImage else { return }
        delegate!.getTextFromImage(textImage: cgImage, mode: scanMode)
    }
}
