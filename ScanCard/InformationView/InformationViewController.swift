//
//  InformationViewController.swift
//  ScanCard
//
//  Created by admin on 08/04/2021.
//

import Foundation
import UIKit
import Vision

class CardView:UIImageView {
    
    lazy var textLayer:CATextLayer = {
        let textLayer = CATextLayer()
        let myAttributes = [
            NSAttributedString.Key.font: UIFont(name: "Chalkduster", size: 30.0)! ,
            NSAttributedString.Key.foregroundColor: UIColor.cyan
        ]
        textLayer.contentsScale = UIScreen.main.scale
        let myAttributedString = NSAttributedString(string: "Name", attributes: myAttributes )
        textLayer.string = myAttributedString
        return textLayer
    }()
    
    lazy var shapeLayer:CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.borderColor = UIColor.white.cgColor
        shapeLayer.borderWidth = 2.0
        shapeLayer.fillColor = UIColor.white.withAlphaComponent(0.5).cgColor
        return shapeLayer
    }()
    
    enum ScanTypelayer:String {
        case name
        case accountBank
        case dateCreated
        case dateExpire
    }
    
    var type:ScanTypelayer!
    var resultString:String?
    var firtPoint:CGPoint = CGPoint.zero
    var endPoint:CGPoint = CGPoint.zero
    var mrect:CGRect?
    
    private func drawScanRect(rec:CGRect) {
        
        self.shapeLayer.path = UIBezierPath(roundedRect: rec, cornerRadius: 10).cgPath
        self.shapeLayer.borderColor = UIColor.white.cgColor
        self.shapeLayer.borderWidth = 2.0
        self.shapeLayer.fillColor = UIColor.white.withAlphaComponent(0.5).cgColor
        
        let tmpFrame = CGRect(x: rec.minX-10, y: rec.minY-10, width: 200, height: 100)
        textLayer.frame = tmpFrame
        
        self.shapeLayer.addSublayer(textLayer)
        self.layer.addSublayer(self.shapeLayer)

    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let touch = touches.first?.location(in: self)
        firtPoint = touch ?? CGPoint.zero
        print("touchesBegan is \(touch as Any)")
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        let touch = touches.first?.location(in: self)
        endPoint = touch ?? CGPoint.zero
        let rect = CGRect(x: min(firtPoint.x, endPoint.x), y: min(firtPoint.y, endPoint.y), width: abs(firtPoint.x - endPoint.x), height: abs(firtPoint.y - endPoint.y))
        self.drawScanRect(rec: rect)
        self.mrect = rect
        print("touchesMoved is \(touch as Any)")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let mimage = snapshot(in: self, rect: self.mrect!)
        self.image = mimage
        //self.getCardInformation(ciimage: image.ciImage!)
    }
    
    func snapshot(in imageView: UIImageView, rect: CGRect) -> UIImage {
        return UIGraphicsImageRenderer(bounds: rect).image { _ in
            imageView.drawHierarchy(in: imageView.bounds, afterScreenUpdates: true)
        }
    }
    
    func getCardInformation(ciimage:CIImage) {
        let request = VNRecognizeTextRequest { (request, error) in
            guard let observations =
                    request.results as? [VNRecognizedTextObservation] else {
                return
            }
            
            let recognizedStrings = observations.compactMap { observation in
                // Return the string of the top VNRecognizedText instance.
                return observation.topCandidates(1).first?.string
            }
            
            print(recognizedStrings)
        }
        request.recognitionLevel = .accurate
        
        
        //let rotateImage = ciimage.oriented(.right)
        let requestTextHandler = VNImageRequestHandler(ciImage: ciimage, options: [:])
        try? requestTextHandler.perform([request])
    }
    
}

class InformationViewcontroller:UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var numTextField: UITextField!
    @IBOutlet weak var DateCreatedTextField: UITextField!
    @IBOutlet weak var DateExpireTextField: UITextField!
    @IBOutlet weak var cardImageView: CardView!
    @IBOutlet weak var infoCardLabel: UILabel!
    
    var cardImage:UIImage?
    var mRecognizedStrings:[String]?
    var tmpString:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        cardImageView.isUserInteractionEnabled = true
        infoCardLabel.backgroundColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cardImageView.image = cardImage
        mRecognizedStrings?.forEach({tmpString.append("\($0)\n")})
        //infoCardLabel.text = tmpString
    }
    
    
}
