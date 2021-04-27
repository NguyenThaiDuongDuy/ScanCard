//
//  ShadowView.swift
//  ScanCard
//
//  Created by admin on 20/04/2021.
//

import UIKit

class ShadowView: UIView {

    private var shadowLayer: CAShapeLayer?
    var color: UIColor?
    var cornerRadius: CGFloat?

    override func layoutSubviews() {
        super.layoutSubviews()

        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            shadowLayer?.path = UIBezierPath(roundedRect: bounds, cornerRadius: self.cornerRadius ?? 30).cgPath
            shadowLayer?.fillColor = UIColor.white.cgColor

            shadowLayer?.shadowColor = self.color?.cgColor ?? UIColor.darkGray.cgColor
            shadowLayer?.shadowPath = shadowLayer?.path
            shadowLayer?.shadowOffset = CGSize(width: 2.0, height: 2.0)
            shadowLayer?.shadowOpacity = 0.8
            shadowLayer?.shadowRadius = 2

            layer.insertSublayer(shadowLayer ?? CAShapeLayer(), at: 0)
        }
    }
}
