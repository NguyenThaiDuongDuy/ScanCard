//
//  ScanTextCollectionView.swift
//  ScanCard
//
//  Created by admin on 16/04/2021.
//

import Foundation
import UIKit

class ScanTextCollectionView: UICollectionView {

    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view.isKind(of: CardView.self) {
            return false
        }
        if view.isKind(of: UITextField.self) {
            return true
        }

        return super.touchesShouldCancel(in: view)
    }
}
