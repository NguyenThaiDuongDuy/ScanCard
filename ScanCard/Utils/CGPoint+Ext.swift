//
//  CGPoint+Ext.swift
//  ScanCard
//
//  Created by admin on 14/04/2021.
//

import UIKit
extension CGPoint {
    func scaled(to size: CGSize) -> CGPoint {
        return CGPoint(x: self.x * size.width,
                       y: self.y * size.height)
    }
}
