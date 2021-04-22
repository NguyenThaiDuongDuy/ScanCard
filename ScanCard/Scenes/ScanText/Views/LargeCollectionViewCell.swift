//
//  LargeCollectionViewCell.swift
//  ScanCard
//
//  Created by admin on 13/04/2021.
//

import UIKit

protocol LargeCellDelegate: AnyObject {
    func getCardInfo(cardModel: Card?)
}

class LargeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var cardImageView: CardImageView!
    @IBOutlet weak var optionsScanCollectionView: UICollectionView!
    @IBOutlet weak var cardHolderTextField: UITextField!
    @IBOutlet weak var cardNumberTextField: UITextField!
    @IBOutlet weak var issueDateTextField: UITextField!
    @IBOutlet weak var expiryDateTextField: UITextField!
    @IBOutlet weak var cardHolderLabel: UILabel!
    @IBOutlet weak var cardNumberLabel: UILabel!
    @IBOutlet weak var issueDateLabel: UILabel!
    @IBOutlet weak var expiryDateLabel: UILabel!
    @IBOutlet weak var shadowView: ShadowView!
    @IBOutlet weak var confirmButton: BlueStyleButton!
    @IBOutlet weak var stackView: UIStackView!
    weak var delegate: LargeCellDelegate?
    var cardImage: UIImage?
    let options: [String] = ["Card Holder",
                            "Card Number",
                            "Issue Date",
                            "Expiry Date"
                            ]
    static let cellID = "OptionCollectionViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        setUpCardImageView()
        setUpoptionsScanCollectionView()
        setDefaultSelectedcell()
        setUpconfirmButton()
        setUpTitleLabel()
    }

    func setUpTitleLabel() {
        for stackView in stackView.subviews {
            for view in stackView.subviews {
                if view.isKind(of: UILabel.self) {
                    guard let label = view as? UILabel else { return }
                    label.text = options[label.tag]
                }
            }
        }
    }

    func setUpconfirmButton () {
        confirmButton.setTitle("Confirm", for: .normal)
    }

    private func setDefaultSelectedcell() {
        let indexPath = IndexPath(item: 0, section: 0)
        self.optionsScanCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
        cardImageView.setTextForScanLayer(option: options[indexPath.item])
    }
    override func layoutSubviews() {
        super.layoutSubviews()
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
        guard let layout = optionsScanCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
    }

    @IBAction func tapConfirmButton(_ sender: Any) {
        self.delegate?.getCardInfo(cardModel: Card(cardHolder: cardHolderTextField.text,
                                                   cardNumber: cardNumberTextField.text,
                                                   issueDate: issueDateTextField.text,
                                                   expiryDate: expiryDateTextField.text))
    }
}

extension LargeCollectionViewCell: CardViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    func getResultStrings(results: [String]?, type: String) {
        guard let resultStrings = results, !resultStrings.isEmpty else { return }
        let result = resultStrings.first
        switch type {
        case "Card Holder":
            self.cardHolderTextField.text = result
        case "Card Number":
            self.cardNumberTextField.text = result
        case "Issue Date":
            self.issueDateTextField.text = result
        case "Expiry Date":
            self.expiryDateTextField.text = result

        default:
            print("error")
        }
    }

    func setInfotoTextFiled(scanTextViewModel: ScanTextViewModel?) {
        guard let info = scanTextViewModel else { return }
        DispatchQueue.main.async {
            self.cardHolderTextField.text = info.cardModel?.cardHolder
            self.cardNumberTextField.text = info.cardModel?.cardNumber
            self.issueDateTextField.text = info.cardModel?.issueDate
            self.expiryDateTextField.text = info.cardModel?.expiryDate
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        options.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LargeCollectionViewCell.cellID,
                                                            for: indexPath)
                as? OptionCollectionViewCell else { return UICollectionViewCell() }

        cell.optionLabel.text = options[indexPath.item]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let type = options[indexPath.item]
        cardImageView.setTextForScanLayer(option: type)
    }
}
