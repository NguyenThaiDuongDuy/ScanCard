//
//  CardView.swift
//  
//
//  Created by admin on 15/04/2021.
//

import Foundation
import UIKit

protocol CardViewDelegate: AnyObject {
    func getTextFromImage(textImage: CGImage, mode: String)
}

class CardImageView: UIImageView {

    weak var delegate: CardViewDelegate?
    var modeScan: String? {
        didSet {
            let attributes = [
                NSAttributedString.Key.font: UIFont(name: "Chalkduster", size: 15.0)! ,
                NSAttributedString.Key.foregroundColor: UIColor.cyan
            ]
            let myAttributedString = NSAttributedString(string: Language.share.localized(string: modeScan ?? ""),
                                                        attributes: attributes )
            titleOfScanArea.string = myAttributedString
        }
    }

    lazy var titleOfScanArea: CATextLayer = {
        let titleOfScanArea = CATextLayer()
        titleOfScanArea.contentsScale = UIScreen.main.scale
        return titleOfScanArea
    }()

    lazy var scanArea: CAShapeLayer = {
        let scanArea = CAShapeLayer()
        scanArea.borderColor = UIColor.white.cgColor
        scanArea.borderWidth = 2.0
        scanArea.fillColor = UIColor.white.withAlphaComponent(0.5).cgColor
        return scanArea
    }()

    var firstPoint: CGPoint = CGPoint.zero
    var endPoint: CGPoint = CGPoint.zero
    var boundingRect: CGRect?

    func setMode(modeScan: String) {
        self.modeScan = modeScan
    }

    private func drawScanRect(rect: CGRect) {

        self.scanArea.path = UIBezierPath(roundedRect: rect, cornerRadius: 10).cgPath
        self.scanArea.borderColor = UIColor.white.cgColor
        self.scanArea.borderWidth = 2.0
        self.scanArea.fillColor = UIColor.white.withAlphaComponent(0.5).cgColor

        let titleFrame = CGRect(x: rect.minX, y: rect.minY - 20, width: 200, height: 100)
        titleOfScanArea.frame = titleFrame

        self.scanArea.addSublayer(titleOfScanArea)
        self.layer.addSublayer(self.scanArea)
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
        self.drawScanRect(rect: rect)
        self.boundingRect = rect
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.layer.sublayers?.removeAll()
        let snapshotImage = self.snapshot(of: self.boundingRect)
        guard let cgImage = snapshotImage?.cgImage else { return }
        self.delegate!.getTextFromImage(textImage: cgImage, mode: self.modeScan ?? "")
    }
}
