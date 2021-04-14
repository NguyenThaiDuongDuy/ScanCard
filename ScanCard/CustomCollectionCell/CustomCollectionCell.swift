//
//  CustomCollectionCellCollectionViewCell.swift
//  ChosseCollection
//
//  Created by admin on 13/04/2021.
//

import UIKit

class CustomCollectionCell: UICollectionViewCell {
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
        customContentView.backgroundColor = UIColor.purple.withAlphaComponent(0.25)
    }
    
    override var isSelected: Bool {
        didSet {
            customContentView.backgroundColor = isSelected ? UIColor.purple:UIColor.purple.withAlphaComponent(0.25)
        }
    }
    
}
