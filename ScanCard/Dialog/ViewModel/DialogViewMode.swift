//
//  DialogViewMode.swift
//  ScanCard
//
//  Created by admin on 16/04/2021.
//

import Foundation

class DialogViewModel {

    var title: String?
    var message: String?
    var cancelButtonTitle: String?
    var okButtonTitle: String?

    init(dialogInfo: Dialog, resultCheckInfo: Result) {
        title = dialogInfo.title
        okButtonTitle = dialogInfo.okButtonTitle
        cancelButtonTitle = dialogInfo.cancelButtonTitle
        switch resultCheckInfo {
        case .invalidCardHolder:
            message = Result.invalidCardHolder.rawValue

        case .invalidCardNumber:
            message = Result.invalidCardNumber.rawValue

        case .invalidIssueDate:
            message = Result.invalidIssueDate.rawValue

        case .invalidExpiryDate:
            message = Result.invalidExpiryDate.rawValue

        default:
            message = Result.success.rawValue
        }
    }
}
