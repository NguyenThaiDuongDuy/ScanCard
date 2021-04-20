//
//  DialogView.swift
//  ScanCard
//
//  Created by admin on 06/04/2021.
//

import Foundation
import UIKit

class DialogView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    var dialogInfoViewModel: DialogViewModel? {
        didSet {
            self.titleLabel.text = dialogInfoViewModel?.dialogInfoModel?.title
            self.messageLabel.text = dialogInfoViewModel?.dialogInfoModel?.message
            self.cancelButton.setTitle(dialogInfoViewModel?.dialogInfoModel?.cancelButtonTitle, for: .normal)
            self.okButton.setTitle(dialogInfoViewModel?.dialogInfoModel?.okButtonTitle, for: .normal)
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
        Bundle.main.loadNibNamed("DialogView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.frame
    }

    @IBAction func tapCancelButton(_ sender: Any) {
        removeFromSuperview()
    }

    @IBAction func tapOkButton(_ sender: Any) {
        removeFromSuperview()
    }
}
