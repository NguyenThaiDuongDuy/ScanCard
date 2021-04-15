//
//  UIView+Ext.swift
//  ScanCard
//
//  Created by admin on 14/04/2021.
//

import UIKit

extension UIView {

    func snapshot(of rect: CGRect? = nil) -> UIImage? {

        UIGraphicsBeginImageContextWithOptions(bounds.size, true, 0.0)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let wholeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        // if no rect provided, return image of whole view

        guard let image = wholeImage, let rect = rect else { return wholeImage }

        // otherwise, grab specified `rect` of image

        let scale = image.scale
        let scaledRect = CGRect(x: rect.origin.x * scale,
                                y: rect.origin.y * scale,
                                width: rect.size.width * scale,
                                height: rect.size.height * scale)
        guard let cgImage = image.cgImage?.cropping(to: scaledRect) else { return nil }
        return UIImage(cgImage: cgImage, scale: scale, orientation: .up)
    }

}

class ShadowView: UIView {

    private var shadowLayer: CAShapeLayer!
    var color: UIColor?
    var cornerRadius: CGFloat?

    override func layoutSubviews() {
        super.layoutSubviews()

        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: self.cornerRadius ?? 30).cgPath
            shadowLayer.fillColor = UIColor.white.cgColor

            shadowLayer.shadowColor = self.color?.cgColor ?? UIColor.darkGray.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 2.0, height: 2.0)
            shadowLayer.shadowOpacity = 0.8
            shadowLayer.shadowRadius = 2

            layer.insertSublayer(shadowLayer, at: 0)
        }
    }
}
