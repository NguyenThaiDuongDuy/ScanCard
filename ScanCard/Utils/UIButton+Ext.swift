//
//  UIButton+Ext.swift
//  ScanCard
//
//  Created by admin on 16/04/2021.
//

import Foundation
import UIKit

extension UIButton {
    func applyStyle () {
        self.backgroundColor = UIColor(rgb: 0x22A7F0)
        self.tintColor = .white
        self.layer.cornerRadius = self.bounds.height / 2
    }
}
