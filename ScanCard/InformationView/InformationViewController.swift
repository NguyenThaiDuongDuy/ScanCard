//
//  InformationViewController.swift
//  ScanCard
//
//  Created by admin on 08/04/2021.
//

import Foundation
import UIKit
import Vision

enum ScanTypelayer:String {
    case name
    case bankNumber
    case dateCreated
    case dateExpire
}

protocol CardviewDelegate {
    func getResultStrings(results:[String]?, type:String) -> Void
    func getResultStrings1(results:[String]?, type:String) -> Void
}

class CardView:UIImageView {
    
    var cardViewDelegate:CardviewDelegate?
    var type:String?
    
    lazy var textLayer:CATextLayer = {
        let textLayer = CATextLayer()
        textLayer.contentsScale = UIScreen.main.scale
        return textLayer
    }()
    
    lazy var shapeLayer:CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.borderColor = UIColor.white.cgColor
        shapeLayer.borderWidth = 2.0
        shapeLayer.fillColor = UIColor.white.withAlphaComponent(0.5).cgColor
        return shapeLayer
    }()

    
    
    var resultString:[String]?
    var firtPoint:CGPoint = CGPoint.zero
    var endPoint:CGPoint = CGPoint.zero
    var mrect:CGRect?
    
    func setTextForScanLayer(String:String) {
        self.type = String
        let myAttributes = [
            NSAttributedString.Key.font: UIFont(name: "Chalkduster", size: 15.0)! ,
            NSAttributedString.Key.foregroundColor: UIColor.cyan
        ]
        let myAttributedString = NSAttributedString(string: String, attributes: myAttributes )
        textLayer.string = myAttributedString
    }
    
    private func drawScanRect(rec:CGRect) {
        
        self.shapeLayer.path = UIBezierPath(roundedRect: rec, cornerRadius: 10).cgPath
        self.shapeLayer.borderColor = UIColor.white.cgColor
        self.shapeLayer.borderWidth = 2.0
        self.shapeLayer.fillColor = UIColor.white.withAlphaComponent(0.5).cgColor
        
        let tmpFrame = CGRect(x: rec.minX, y: rec.minY-20, width: 200, height: 100)
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
        self.layer.sublayers?.removeAll()
        //let mImage = snapshot(in: self, rect: self.mrect!)
        let mImage  = self.snapshot(of: self.mrect)
        guard let cgImage = mImage?.cgImage else {return}
        self.getCardInformation(cgImage: cgImage)
    }

    func getCardInformation(cgImage:CGImage) {
        let request = VNRecognizeTextRequest { (request, error) in
            guard let observations =
                    request.results as? [VNRecognizedTextObservation] else {
                return
            }
            
            let recognizedStrings = observations.compactMap { observation in
                // Return the string of the top VNRecognizedText instance.
                return observation.topCandidates(1).first?.string
            }
            
            self.cardViewDelegate?.getResultStrings(results: recognizedStrings,type: self.type ?? "")
            self.cardViewDelegate?.getResultStrings1(results: recognizedStrings,type: self.type ?? "")
        }
        request.recognitionLevel = .accurate
        let requestTextHandler = VNImageRequestHandler(cgImage: cgImage, orientation: .up, options: [:])
        try? requestTextHandler.perform([request])
    }
    
}

class InformationViewcontroller:UIViewController  {
    @IBOutlet weak var cardImageView: CardView!
    @IBOutlet weak var chossenCollectionView: UICollectionView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var bankNumberTextField: UITextField!
    @IBOutlet weak var creadteadDateTextField: UITextField!
    @IBOutlet weak var expireDateTextField: UITextField!
    var cardImage:UIImage?
    var mRecognizedStrings:[String]?
    var tmpString:String = ""
    let options:[String] = ["Name",
                            "Bank Number",
                            "Creadted Date",
                            "Validate Date"
                            ]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        cardImageView.isUserInteractionEnabled = true
        cardImageView.cardViewDelegate = self
        cardImageView.image = cardImage
        cardImageView.contentMode = .scaleAspectFit
        //cardImageView.textLayer.string = NSString(string: "aaa")
        
        
        let nib = UINib(nibName: "CustomCollectionCell", bundle: .main)
        chossenCollectionView.register(nib, forCellWithReuseIdentifier: "CustomCollectionCell")
        chossenCollectionView.delegate = self
        chossenCollectionView.dataSource = self
        setupCollectionView()
    }
    
    func setupCollectionView() {
        chossenCollectionView.translatesAutoresizingMaskIntoConstraints = false
        chossenCollectionView.showsHorizontalScrollIndicator = false
        let layout = chossenCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
    }
    
}

extension InformationViewcontroller: CardviewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    func getResultStrings1(results: [String]?, type: String) {
        guard let resultStrings = results else {return}
        let result = resultStrings[0]
        switch type {
        case "Name":
            self.nameTextField.text = result
            break
        case "Bank Number":
            self.bankNumberTextField.text = result
            break
        case "Creadted Date":
            self.creadteadDateTextField.text = result
            break
        case "Validate Date":
            self.expireDateTextField.text = result
            break
        default:
            print("error")
        }
    }
    
    func getResultStrings(results: [String]?, type: String) {
        guard let resultStrings = results else {return}
        let result = resultStrings[0]
        switch type {
        case "Name":
            self.nameTextField.text = result
            break
        case "Bank Number":
            self.bankNumberTextField.text = result
            break
        case "Creadted Date":
            self.creadteadDateTextField.text = result
            break
        case "Validate Date":
            self.expireDateTextField.text = result
            break
        default:
            print("error")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCollectionCell", for: indexPath) as! CustomCollectionCell
        cell.nameOfcell.text = options[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let type = options[indexPath.item]
        cardImageView.setTextForScanLayer(String: type)
    }
    
   
    
}


    
