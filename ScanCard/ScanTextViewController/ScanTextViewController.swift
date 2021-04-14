//
//  ScanTextViewController.swift
//  ScanCard
//
//  Created by admin on 13/04/2021.
//

import UIKit

struct ScanTextViewControllerViewModel {
    var cardImage:UIImage?
    var nameCard:String?
    var bankNumber:String?
    var createdDate:String?
    var expireDate:String?
    
    init(cardimage:UIImage,namecard:String?, banknumber:String?, createdDate:String?, expireDate:String? ) {
        self.cardImage = cardimage
        self.nameCard = namecard
        self.bankNumber = banknumber
        self.createdDate = createdDate
        self.expireDate = expireDate
    }
    
//    func checkValidNameCard(namecard:String) {
//
//    }
//
//    func checkValidateNameCard(namecard:String) {
//
//    }
//
//    func checkValidateNameCard(namecard:String) {
//
//    }
//
//    func checkValidateNameCard(namecard:String) {
//
//    }
}

class ScanTextViewController:UIViewController {
    
    @IBOutlet weak var scanCollectionView: UICollectionView!
    var cardImage:UIImage?
    static let cellID = "LargeCollectionViewCell"
    
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
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 650)
        self.scanCollectionView.register(nib, forCellWithReuseIdentifier: ScanTextViewController.cellID)
        self.scanCollectionView.collectionViewLayout = layout
        self.scanCollectionView.alwaysBounceVertical = false
        self.scanCollectionView.delegate = self
        self.scanCollectionView.dataSource  = self
    }
    
    private func registerEventKeyBoard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func deregisterEventKeyBoard() {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerEventKeyBoard()
        
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification:NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)

        var contentInset:UIEdgeInsets = self.scanCollectionView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 20
        scanCollectionView.contentInset = contentInset
    }

    @objc func keyboardWillHide(notification:NSNotification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scanCollectionView.contentInset = contentInset
    }
    
    deinit {
        deregisterEventKeyBoard()
    }
    
}

extension ScanTextViewController:UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ScanTextViewController.cellID, for: indexPath) as! LargeCollectionViewCell
        cell.cardImageView.image = cardImage
        return cell
    }
}
