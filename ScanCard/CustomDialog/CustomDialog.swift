//
//  CustomDialog.swift
//  ScanCard
//
//  Created by admin on 06/04/2021.
//

import Foundation
import UIKit

class CustomDialog: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleDialog: UILabel!
    @IBOutlet weak var messageDialog: UILabel!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    var dialogInfoViewModel: DialogViewModel? {
        didSet {
            self.titleDialog.text = dialogInfoViewModel?.diainfo?.tile
            self.messageDialog.text = dialogInfoViewModel?.diainfo?.message
            self.cancelButton.setTitle(dialogInfoViewModel?.diainfo?.cancelTitleButton, for: .normal)
            self.okButton.setTitle(dialogInfoViewModel?.diainfo?.okTitleButton, for: .normal)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func commonInit() {
        Bundle.main.loadNibNamed("CustomDialog", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.frame
    }

    @IBAction func tapCancelButton(_ sender: Any) {
        removeFromSuperview()
        print("tapCancelButton")
    }
    @IBAction func tapOkButton(_ sender: Any) {
        removeFromSuperview()
        print("tapOkButton")
    }
}
