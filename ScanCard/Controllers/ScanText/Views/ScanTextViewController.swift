//
//  ScanTextViewController.swift
//  ScanCard
//
//  Created by admin on 13/04/2021.
//

import UIKit

class ScanTextViewController: UIViewController {

    @IBOutlet weak var scanCollectionView: ScanTextCollectionView!
    var cardImage: UIImage?
    static let cellID = "LargeCollectionViewCell"
    var scanTextViewModel: ScanTextViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpScanCollectionView()
        configHiddenKeyboard()
    }

    private func configHiddenKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    private func setUpScanCollectionView () {
        let nib = UINib(nibName: ScanTextViewController.cellID, bundle: Bundle.main)
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        self.scanCollectionView.register(nib, forCellWithReuseIdentifier: ScanTextViewController.cellID)
        self.scanCollectionView.collectionViewLayout = layout
        self.scanCollectionView.alwaysBounceVertical = false
        self.scanCollectionView.delegate = self
        self.scanCollectionView.dataSource = self
        self.scanCollectionView.delaysContentTouches = true
    }

    private func registerEventKeyBoard() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerEventKeyBoard()
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        guard var keyboardFrame: CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey]
                                            as? NSValue)?.cgRectValue else { return }
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)

        var contentInset: UIEdgeInsets = self.scanCollectionView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 20
        scanCollectionView.contentInset = contentInset
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInset: UIEdgeInsets = UIEdgeInsets.zero
        scanCollectionView.contentInset = contentInset
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        scanTextViewModel = nil
    }
}

extension ScanTextViewController: UICollectionViewDelegate,
                                  UICollectionViewDataSource,
                                  UICollectionViewDelegateFlowLayout,
                                  LargeCellDelegate {
    func getCardInfo(cardModel: CardModel?) {
        guard let cardModel = cardModel else {
            return
        }
        scanTextViewModel?.checkValidInfo(cardModel: cardModel) { (result) in
            DispatchQueue.main.async {
                let diaLog = DialogView(frame: self.view.bounds)
                var message: String
                var title = "Error"
                let titleOfOkButton = "Ok"
                let titleOfCancelButton = "Cancel"
                switch result {
                case .invalidCardHolder :
                    message = Result.invalidCardHolder.rawValue

                case .invalidCardNumber :
                    message = Result.invalidCardNumber.rawValue

                case .invalidIssueDate :
                    message = Result.invalidIssueDate.rawValue

                case .invalidExpiryDate :
                    message = Result.invalidExpiryDate.rawValue

                default :
                    title = "Success"
                    message = Result.success.rawValue
                }
                    diaLog.dialogInfoViewModel = DialogViewModel(dialogInfoModel:
                                                                    DialogModel(title: title,
                                                                                message: message,
                                                                                okButtonTitle: titleOfOkButton,
                                                                                cancelButtonTitle: titleOfCancelButton))
                    self.view.addSubview(diaLog)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         1
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ScanTextViewController.cellID,
                                                            for: indexPath)
                as? LargeCollectionViewCell
        else { return UICollectionViewCell() }
        cell.delegate = self
        cell.cardImageView.image = self.cardImage
        cell.setInfotoTextFiled(scanTextViewModel: scanTextViewModel)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
         CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
}
