//
//  CardView.swift
//  
//
//  Created by admin on 15/04/2021.
//

import Foundation
import UIKit
import Vision

protocol CardViewDelegate: AnyObject {
    func getResultStrings(results: [String]?, type: String)
}

class CardImageView: UIImageView {

    weak var cardViewDelegate: CardViewDelegate?
    var type: String?

    lazy var textLayer: CATextLayer = {
        let textLayer = CATextLayer()
        textLayer.contentsScale = UIScreen.main.scale
        return textLayer
    }()

    lazy var shapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.borderColor = UIColor.white.cgColor
        shapeLayer.borderWidth = 2.0
        shapeLayer.fillColor = UIColor.white.withAlphaComponent(0.5).cgColor
        return shapeLayer
    }()

    var firstPoint: CGPoint = CGPoint.zero
    var endPoint: CGPoint = CGPoint.zero
    var boundingRect: CGRect?

    func setTextForScanLayer(option: String) {
        self.type = option
        let myAttributes = [
            NSAttributedString.Key.font: UIFont(name: "Chalkduster", size: 15.0)! ,
            NSAttributedString.Key.foregroundColor: UIColor.cyan
        ]
        let myAttributedString = NSAttributedString(string: option, attributes: myAttributes )
        textLayer.string = myAttributedString
    }

    private func drawScanRect(rect: CGRect) {

        self.shapeLayer.path = UIBezierPath(roundedRect: rect, cornerRadius: 10).cgPath
        self.shapeLayer.borderColor = UIColor.white.cgColor
        self.shapeLayer.borderWidth = 2.0
        self.shapeLayer.fillColor = UIColor.white.withAlphaComponent(0.5).cgColor

        let tmpFrame = CGRect(x: rect.minX, y: rect.minY - 20, width: 200, height: 100)
        textLayer.frame = tmpFrame

        self.shapeLayer.addSublayer(textLayer)
        self.layer.addSublayer(self.shapeLayer)
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
        let mImage = self.snapshot(of: self.boundingRect)
        guard let cgImage = mImage?.cgImage else { return }
        self.getCardInformation(cgImage: cgImage)
    }

    func getCardInformation(cgImage: CGImage) {
        let request = VNRecognizeTextRequest { (request, _) in
            guard let observations =
                    request.results as? [VNRecognizedTextObservation] else {
                return
            }

            let recognizedStrings = observations.compactMap { observation in
                // Return the string of the top VNRecognizedText instance.
                return observation.topCandidates(1).first?.string
            }
            self.cardViewDelegate?.getResultStrings(results: recognizedStrings, type: self.type ?? "")
        }
        request.recognitionLevel = .accurate
        let requestTextHandler = VNImageRequestHandler(cgImage: cgImage, orientation: .up, options: [:])
        try? requestTextHandler.perform([request])
    }
}
