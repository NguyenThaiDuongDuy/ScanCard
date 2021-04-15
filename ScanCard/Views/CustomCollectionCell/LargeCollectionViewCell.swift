//
//  LargeCollectionViewCell.swift
//  ScanCard
//
//  Created by admin on 13/04/2021.
//

import UIKit

class LargeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var cardImageView: CardView!
    @IBOutlet weak var optionsScanCollectionView: UICollectionView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var bankNumberTextField: UITextField!
    @IBOutlet weak var creadteadDateTextField: UITextField!
    @IBOutlet weak var expireDateTextField: UITextField!
    @IBOutlet weak var shadowView: ShadowView!

    var cardImage: UIImage?
    let options: [String] = ["Name",
                            "Bank Number",
                            "Creadted Date",
                            "Validate Date"
                            ]
    static let cellID = "CustomCollectionCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        setUpCardImageView()
        setUpoptionsScanCollectionView()
        setDefaultSelectedcell()
    }

    private func setDefaultSelectedcell() {
        let indexPath = IndexPath(item: 0, section: 0)
        self.optionsScanCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
        cardImageView.setTextForScanLayer(option: options[indexPath.item])

    }
    override func layoutSubviews() {
        setUpShadowView()
    }

    private func setUpShadowView() {
        shadowView.cornerRadius = 15.0
    }

    private func setUpCardImageView() {
        cardImageView.isUserInteractionEnabled = true
        cardImageView.cardViewDelegate = self
        cardImageView.image = cardImage
        cardImageView.contentMode = .scaleAspectFit
    }

    private func setUpoptionsScanCollectionView() {
        let nib = UINib(nibName: LargeCollectionViewCell.cellID, bundle: .main)
        optionsScanCollectionView.register(nib, forCellWithReuseIdentifier: LargeCollectionViewCell.cellID)
        optionsScanCollectionView.delegate = self
        optionsScanCollectionView.dataSource = self
        optionsScanCollectionView.translatesAutoresizingMaskIntoConstraints = false
        optionsScanCollectionView.showsHorizontalScrollIndicator = false
        guard let layout = optionsScanCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else {return}
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
    }

}

extension LargeCollectionViewCell: cardviewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    func getResultStrings(results: [String]?, type: String) {
        guard let resultStrings = results, !resultStrings.isEmpty else {return}
        let result = resultStrings[0]
        switch type {
        case "Name":
            self.nameTextField.text = result
        case "Bank Number":
            self.bankNumberTextField.text = result
        case "Creadted Date":
            self.creadteadDateTextField.text = result
        case "Validate Date":
            self.expireDateTextField.text = result
        default:
            print("error")
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier:LargeCollectionViewCell.cellID,
                                                            for: indexPath)
                as? CustomCollectionCell else {return UICollectionViewCell()}

        cell.nameOfcell.text = options[indexPath.item]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let type = options[indexPath.item]
        cardImageView.setTextForScanLayer(option: type)
    }

}
