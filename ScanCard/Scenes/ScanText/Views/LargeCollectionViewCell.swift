//
//  LargeCollectionViewCell.swift
//  ScanCard
//
//  Created by admin on 13/04/2021.
//

import UIKit

protocol LargeCellDelegate: AnyObject {
    func getCardInfo(cardInfo: Card?)
}

class LargeCollectionViewCell: UICollectionViewCell {

    static let cellID = "OptionCollectionViewCell"
    let scanModes: [String] = ["Card Holder",
                            "Card Number",
                            "Issue Date",
                            "Expiry Date"
                            ]
    @IBOutlet weak var cardView: CardImageView!
    @IBOutlet weak var optionsScanView: UICollectionView!
    @IBOutlet weak var cardHolderInput: UITextField!
    @IBOutlet weak var cardNumberInput: UITextField!
    @IBOutlet weak var issueDateInput: UITextField!
    @IBOutlet weak var expiryDateInput: UITextField!
    @IBOutlet weak var cardHolderTitle: UILabel!
    @IBOutlet weak var cardNumberTitle: UILabel!
    @IBOutlet weak var issueDateTitle: UILabel!
    @IBOutlet weak var expiryDateTitle: UILabel!
    @IBOutlet weak var shadowOfInformationView: ShadowView!
    @IBOutlet weak var confirmButton: BlueStyleButton!
    @IBOutlet weak var informationView: UIStackView!
    weak var delegate: LargeCellDelegate?
    var cardImage: UIImage?

    override func awakeFromNib() {
        super.awakeFromNib()
        setUpCardView()
        setUpOptionsScanCollectionView()
        setDefaultSelectedCell()
        setUpConfirmButton()
        setUpTitleInfoView()
    }

    func setUpTitleInfoView() {
        for stackView in informationView.subviews {
            for view in stackView.subviews {
                if view.isKind(of: UILabel.self) {
                    guard let label = view as? UILabel else { return }
                    label.text = Language.share.localized(string: scanModes[label.tag])
                }
            }
        }
    }

    func setUpConfirmButton () {
        confirmButton.setTitle(Language.share.localized(string: "Confirm"), for: .normal)
    }

    private func setDefaultSelectedCell() {
        let defaultIndexPath = IndexPath(item: 0, section: 0)
        optionsScanView.selectItem(at: defaultIndexPath, animated: false, scrollPosition: .top)
        cardView.setMode(modeScan: scanModes[defaultIndexPath.item])
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        setUpShadowView()
    }

    private func setUpShadowView() {
        shadowOfInformationView.cornerRadius = 15.0
    }

    private func setUpCardView() {
        cardView.isUserInteractionEnabled = true
        cardView.image = cardImage
        cardView.contentMode = .scaleAspectFit
    }

    private func setUpOptionsScanCollectionView() {
        let nib = UINib(nibName: LargeCollectionViewCell.cellID, bundle: .main)
        optionsScanView.register(nib, forCellWithReuseIdentifier: LargeCollectionViewCell.cellID)
        optionsScanView.delegate = self
        optionsScanView.dataSource = self
        optionsScanView.translatesAutoresizingMaskIntoConstraints = false
        optionsScanView.showsHorizontalScrollIndicator = false
        guard let layout = optionsScanView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
    }

    @IBAction func tapConfirmButton(_ sender: Any) {
        delegate?.getCardInfo(cardInfo: Card(cardHolder: cardHolderInput.text,
                                             cardNumber: cardNumberInput.text,
                                             issueDate: issueDateInput.text,
                                             expiryDate: expiryDateInput.text))
    }

    func setInformationToTextFiled(cardInfo: Card?) {
        DispatchQueue.main.async {
            self.cardHolderInput.text = cardInfo?.cardHolder ?? ""
            self.cardNumberInput.text = cardInfo?.cardNumber ?? ""
            self.issueDateInput.text = cardInfo?.issueDate ?? ""
            self.expiryDateInput.text = cardInfo?.expiryDate ?? ""
        }
    }
}

extension LargeCollectionViewCell: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        scanModes.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LargeCollectionViewCell.cellID,
                                                            for: indexPath)
                as? ModeScanCollectionViewCell else { return UICollectionViewCell() }

        cell.modeName.text = Language.share.localized(string: scanModes[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cardView.setMode(modeScan: scanModes[indexPath.item])
    }
}
