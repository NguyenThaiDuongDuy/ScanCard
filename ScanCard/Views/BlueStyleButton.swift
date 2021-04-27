//
//  BlueStyleButton.swift
//  ScanCard
//
//  Created by admin on 20/04/2021.
//

import UIKit

class BlueStyleButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initCommon()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initCommon()
    }
    
    func initCommon() {
        self.backgroundColor = UIColor(rgb: 0x22A7F0)
        self.tintColor = .white
        self.layer.cornerRadius = self.bounds.height / 2
    }
}
