//
//  CustomDialog.swift
//  ScanCard
//
//  Created by admin on 06/04/2021.
//

import Foundation
import UIKit

class CustomDialog:UIView {
    @IBOutlet weak var testLabel: UILabel!
    @IBOutlet var contentView: UIView!
    //    let title:String
//    let message:String
//    let type:String
//    let vc:ViewController
//
//    init(title:String, message:String, type:String, vc:ViewController) {
//        self.title = title
//        self.message = message
//        self.type = type
//        self.vc = vc
//    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
        testLabel.text = "Test"
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("CustomDialog", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.frame
    }
    
    
}
