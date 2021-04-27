//
//  ScanTextViewController.swift
//  ScanCard
//
//  Created by admin on 13/04/2021.
//

import UIKit

class ScanTextViewController: UIViewController {

    init(cardImage: CIImage?) {
        super.init(nibName: String(describing: type(of: self)), bundle: nil)
        viewModel = ScanTextViewModel(image: cardImage)
        viewModel?.delegate = self
        viewModel?.parseCardInfo()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static let cellID = "LargeCollectionViewCell"
    @IBOutlet weak var scanCollectionView: ScanTextCollectionView!
    private var viewModel: ScanTextViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpScanCollectionView()
        configHiddenKeyboard()
    }

    private func configHiddenKeyboard() {
        let tapToHideKeyboard = UITapGestureRecognizer(target: self,
                                                       action: #selector(UIInputViewController.dismissKeyboard))
        tapToHideKeyboard.cancelsTouchesInView = false
        view.addGestureRecognizer(tapToHideKeyboard)
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
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
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
        viewModel = nil
    }
}

extension ScanTextViewController: LargeCellDelegate {

    func getCardInfo(cardInfo: Card?) {
        guard let cardInfo = cardInfo else { return }
        guard let  resultCheckInfo = self.viewModel?.checkValidInfo(cardInfo: cardInfo) else { return }
        let dialogInfo = Dialog(title: "Notice",
                                message: "",
                                okButtonTitle: "Ok",
                                cancelButtonTitle: "Cancel")
        DispatchQueue.main.async {
            let diaLog = DialogView(viewModel:
                                        DialogViewModel(dialogInfo: dialogInfo,
                                                        resultCheckInfo: resultCheckInfo))
            self.view.addSubview(diaLog)
        }
    }
}

extension ScanTextViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         1
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ScanTextViewController.cellID,
                                                            for: indexPath)
                as? LargeCollectionViewCell
        else { return UICollectionViewCell() }
        cell.configCell(data: viewModel, delegate: self)
        return cell
    }
}

extension ScanTextViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
         CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
}

extension ScanTextViewController: CardViewDelegate {
    func getTextFromImage(textImage: CGImage?, mode: String) {
        self.viewModel?.setTextInfoWithMode(textImage: textImage, mode: mode)
    }
}

extension ScanTextViewController: ScanTextViewModelDelegate {
    func didGetCardInfo() {
        DispatchQueue.main.async {
            self.scanCollectionView.reloadData()
        }
    }
}
