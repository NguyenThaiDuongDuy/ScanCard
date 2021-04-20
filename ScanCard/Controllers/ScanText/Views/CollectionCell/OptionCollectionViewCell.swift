//
//  OptionCollectionCell.swift
//  ChosseCollection
//
//  Created by admin on 13/04/2021.
//

import UIKit

class OptionCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var optionLabel: UILabel!
    @IBOutlet weak var optionView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setUpcell()
    }

    private func setUpcell() {
        optionView.clipsToBounds = true
        optionView.layer.cornerRadius = 15.0
        optionView.backgroundColor = UIColor(rgb: 0x22A7F0).withAlphaComponent(0.5)
        optionLabel.textColor = .white
    }

    override var isSelected: Bool {
        didSet {
            optionView.backgroundColor = isSelected ? UIColor(rgb: 0x22A7F0):
                UIColor(rgb: 0x22A7F0).withAlphaComponent(0.5)
        }
    }
}
