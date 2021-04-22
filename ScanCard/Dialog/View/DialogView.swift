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
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    var dialogInfoViewModel: DialogViewModel? {
        didSet {
            self.title.text = dialogInfoViewModel?.dialogInfo?.title
            self.message.text = dialogInfoViewModel?.dialogInfo?.message
            self.cancelButton.setTitle(dialogInfoViewModel?.dialogInfo?.cancelButtonTitle, for: .normal)
            self.okButton.setTitle(dialogInfoViewModel?.dialogInfo?.okButtonTitle, for: .normal)
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

    private func commonInit() {
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
