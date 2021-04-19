//
//  OptionCollectionCell.swift
//  ChosseCollection
//
//  Created by admin on 13/04/2021.
//

import UIKit

class OptionCollectionCell: UICollectionViewCell {
    @IBOutlet weak var nameOfcell: UILabel!
    @IBOutlet weak var customContentView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setUpcell()
    }

    private func setUpcell() {
        customContentView.clipsToBounds = true
        customContentView.layer.cornerRadius = 15.0
        nameOfcell.textColor = .white
        customContentView.backgroundColor = UIColor(rgb: 0x22A7F0).withAlphaComponent(0.5)
    }

    override var isSelected: Bool {
        didSet {
            customContentView.backgroundColor = isSelected ? UIColor(rgb: 0x22A7F0):
                UIColor(rgb: 0x22A7F0).withAlphaComponent(0.5)
        }
    }
}
