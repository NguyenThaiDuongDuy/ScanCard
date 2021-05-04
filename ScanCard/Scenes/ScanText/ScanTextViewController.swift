//
//  ScanTextViewController2.swift
//  ScanCard
//
//  Created by DuyNguyen on 27/04/2021.
//

import UIKit

class ScanTextViewController: UIViewController {

    private let cellID = "ScanModeCollectionViewCell"
    private var viewModel: ScanTextViewModel

    @IBOutlet weak var cardView: CardImageView!
    @IBOutlet weak var optionsScanView: UICollectionView!
    @IBOutlet weak var cardHolderTextField: UITextField!
    @IBOutlet weak var cardNumberTextField: UITextField!
    @IBOutlet weak var issueDateTextField: UITextField!
    @IBOutlet weak var expiryDateTextField: UITextField!
    @IBOutlet weak var cardHolderLabel: UILabel!
    @IBOutlet weak var cardNumberLabel: UILabel!
    @IBOutlet weak var issueDateLabel: UILabel!
    @IBOutlet weak var expiryDateLabel: UILabel!
    @IBOutlet weak var shadowOfInformationView: ShadowView!
    @IBOutlet weak var confirmButton: BlueStyleButton!
    @IBOutlet weak var informationView: UIStackView!
    @IBOutlet weak var scrollView: ScanTextScrollView!

    init(cardImage: CIImage) {
        viewModel = ScanTextViewModel(image: cardImage)
        super.init(nibName: String(describing: type(of: self)), bundle: Bundle(for: type(of: self)))
        setUpViewModel()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpOptionsScanCollectionView()
        configHiddenKeyboard()
        setUpCardView()
        setUpConfirmButton()
        setInformationToTextFiled()
        setDefaultSelectedCell()
        setUpTitleInfoView()
    }

    private func setUpViewModel() {
        viewModel.delegate = self
        viewModel.parseCardInfo()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerEventKeyBoard()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setUpShadowView()
    }

    private func setUpCardView() {
        cardView.delegate = self
        cardView.isUserInteractionEnabled = true
        cardView.image = UIImage(ciImage: viewModel.image)
        cardView.contentMode = .scaleAspectFit
    }

    private func setUpShadowView() {
        shadowOfInformationView.cornerRadius = 15.0
    }

    private func setUpConfirmButton () {
        confirmButton.setTitle(Language.share.localized(string: "Confirm"), for: .normal)
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

    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        guard var keyboardFrame: CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey]
                                            as? NSValue)?.cgRectValue else { return }
        keyboardFrame = view.convert(keyboardFrame, from: nil)

        var contentInset: UIEdgeInsets = scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 20
        scrollView.contentInset = contentInset
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInset: UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }

    private func setUpOptionsScanCollectionView() {
        let nib = UINib(nibName: cellID, bundle: Bundle(for: type(of: self)))
        optionsScanView.register(nib, forCellWithReuseIdentifier: cellID)
        optionsScanView.delegate = self
        optionsScanView.dataSource = self
        optionsScanView.translatesAutoresizingMaskIntoConstraints = false
        optionsScanView.showsHorizontalScrollIndicator = false
        guard let layout = optionsScanView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    private func configHiddenKeyboard() {
        let tapToHideKeyboard = UITapGestureRecognizer(target: self,
                                                       action: #selector(UIInputViewController.dismissKeyboard))
        tapToHideKeyboard.cancelsTouchesInView = false
        view.addGestureRecognizer(tapToHideKeyboard)
    }

    @IBAction func tapConfirmButton(_ sender: Any) {

        let infoCard = Card(cardHolder: cardHolderTextField.text ?? "",
                            cardNumber: cardNumberTextField.text ?? "",
                            issueDate: issueDateTextField.text,
                            expiryDate: expiryDateTextField.text)

        let  resultCheckInfo = viewModel.checkValidInfo(infoCard: infoCard)
        let dialogInfo = Dialog(title: "Notice",
                                message: "",
                                okButtonTitle: "Ok",
                                cancelButtonTitle: "Cancel")
        let diaLog = DialogView(viewModel:
                                    DialogViewModel(dialogInfo: dialogInfo,
                                                    resultCheckInfo: resultCheckInfo))
        view.addSubview(diaLog)
    }

    private func setInformationToTextFiled() {
        cardHolderTextField.text = viewModel.infoCard?.cardHolder ?? ""
        cardNumberTextField.text = viewModel.infoCard?.cardNumber ?? ""
        issueDateTextField.text = viewModel.infoCard?.issueDate ?? ""
        expiryDateTextField.text = viewModel.infoCard?.expiryDate ?? ""
    }

    private func setDefaultSelectedCell() {
        let defaultIndexPath = IndexPath(item: 0, section: 0)
        optionsScanView.selectItem(at: defaultIndexPath, animated: false, scrollPosition: .top)
    }

    private func setUpTitleInfoView() {
        for stackView in informationView.subviews {
            for view in stackView.subviews {
                if view.isKind(of: UILabel.self) {
                    guard let label = view as? UILabel else { return }
                    label.text = Language.share.localized(string: ScanMode.modes[label.tag].modeString)
                }
            }
        }
    }
}

extension ScanTextViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        ScanMode.modes.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID,
                                                            for: indexPath)
                as? ScanModeCollectionViewCell else { return UICollectionViewCell() }

        cell.modeNameLabel.text = Language.share.localized(string: ScanMode.modes[indexPath.item].modeString)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cardView.setMode(scanMode: ScanMode.modes[indexPath.item])
    }
}

extension ScanTextViewController: CardViewDelegate {
    func getTextFromImage(textImage: CGImage, mode: ScanMode) {
        viewModel.setTextInfoWithMode(textImage: textImage, mode: mode)
    }
}

extension ScanTextViewController: ScanTextViewModelDelegate {
    func didGetCardInfo() {
        setInformationToTextFiled()
    }
}
