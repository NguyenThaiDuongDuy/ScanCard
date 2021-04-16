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
    var scanTextViewModel = ScanTextViewModel(userInfor: UserInfoModel(name: "",
                                                                       bankNumber: "",
                                                                       createdDate: "",
                                                                       validDate: ""))

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpScanCollectionView()
        conFighidenKeyboard()
    }

    private func conFighidenKeyboard() {
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
        navigationController?.navigationBar.prefersLargeTitles = false
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
    }
}

extension ScanTextViewController: UICollectionViewDelegate,
                                  UICollectionViewDataSource,
                                  UICollectionViewDelegateFlowLayout,
                                  largeCelldelegate {
    func getCardInfor(userInfo: UserInfoModel?) {
        guard let userInfo = userInfo else {
            return
        }
        scanTextViewModel.checkValidInfo(userInfo: userInfo) { (result) in
            DispatchQueue.main.async {
                if result == .invalidbank {
                    let diaLog = CustomDialog(frame: self.view.bounds)
                    diaLog.dialogInfoViewModel = DialogViewModel(dialoginfo:
                                                                    DialogModel(tile: "Error",
                                                                                message: Result.invalidbank.rawValue,
                                                                                okTitleButton: "Ok",
                                                                                cancelTitleButton: "Cancel"))
                    self.view.addSubview(diaLog)
                }
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
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
         CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
}
