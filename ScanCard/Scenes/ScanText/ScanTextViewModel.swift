//
//  ScanTextViewModel.swift
//  ScanCard
//
//  Created by admin on 16/04/2021.
//

import Foundation
import UIKit

enum Result: String {
    case success
    case invalidCardHolder
    case invalidCardNumber
    case invalidIssueDate
    case invalidExpiryDate
}

class ScanTextViewModel {

    var cardInfo: Card?
    let maxCardNumber = 19
    let minCardNumber = 16

    init(cardInfo: Card) {
        self.cardInfo = cardInfo
    }

    func checkValidInfo(cardInfo: Card) -> Result {

        // Check valid Name
        if !isValidCardHolder(cardHolder: cardInfo.cardHolder ?? "") {
            return Result.invalidCardHolder
        }

        // Check valid bank number
        if !isValidCardNumber(cardNumber: cardInfo.cardNumber ?? "") {
            return Result.invalidCardHolder
        }

        // check valid created date
        if !isValidIssueDate(checkIssueDate: cardInfo.issueDate ?? "") {
            return Result.invalidIssueDate
        }

        // check valid validate date
        if !isValidExpiryDate(checkExpiryDate: cardInfo.expiryDate ?? "") {
            return Result.invalidExpiryDate
        }
        self.cardInfo = cardInfo
        return Result.success
    }

    private func isValidCardNumber(cardNumber: String) -> Bool {
        let vowels: Set<Character> = [" "]
        var checkCardNumber = ""
        checkCardNumber = cardNumber
        checkCardNumber.removeAll(where: { vowels.contains($0) })

        if !checkCardNumber.isNumeric { return false }

        if checkCardNumber.count<minCardNumber || checkCardNumber.count>maxCardNumber {
            return false
        }
        return true
    }

    private func isValidCardHolder(cardHolder: String) -> Bool {
        if !cardHolder.isOnlyUpCaseAndWhiteSpaceCharacter { return false }
        let nameAfterCutWhiteSpacesAndNewlines = cardHolder.components(separatedBy: .whitespacesAndNewlines)
            .filter({ !$0.isEmpty })
            .joined(separator: " ")
        return nameAfterCutWhiteSpacesAndNewlines.contains(" ")
        }

    private func isValidIssueDate(checkIssueDate: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/yy"
        let inputDate = dateFormatter.date(from: checkIssueDate)
        guard let checkInputDate = inputDate else {
            return false }
        return checkInputDate < Date()
    }

    private func isValidExpiryDate(checkExpiryDate: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/yy"
        let inputDate = dateFormatter.date(from: checkExpiryDate)
        guard let checkInputDate = inputDate else { return false }
        return checkInputDate > Date()
    }

    static func getInfoCardAuto(information: [String]?) -> ScanTextViewModel {
        let scanTextViewModel = ScanTextViewModel(cardInfo: Card(cardHolder: "",
                                                                 cardNumber: "",
                                                                 issueDate: "",
                                                                 expiryDate: ""))
        guard let checkInformation = information else { return scanTextViewModel }

        for index in stride(from: checkInformation.count - 1, to: 0, by: -1) {

            if scanTextViewModel.isValidCardHolder(cardHolder: checkInformation[index]) &&
                (((scanTextViewModel.cardInfo?.cardHolder!.isEmpty)!)) {
                scanTextViewModel.cardInfo?.cardHolder = checkInformation[index]
            }

            if scanTextViewModel.isValidCardNumber(cardNumber: checkInformation[index])
                && ((scanTextViewModel.cardInfo?.cardNumber?.isEmpty)!) {
                scanTextViewModel.cardInfo?.cardNumber = checkInformation[index]
            }

            if scanTextViewModel.isValidIssueDate(checkIssueDate: checkInformation[index])
                && ((scanTextViewModel.cardInfo?.issueDate?.isEmpty)!) {
                scanTextViewModel.cardInfo?.issueDate = checkInformation[index]
            }

            if scanTextViewModel.isValidExpiryDate(checkExpiryDate: checkInformation[index])
                && ((scanTextViewModel.cardInfo?.expiryDate?.isEmpty)!) {
                scanTextViewModel.cardInfo?.expiryDate = checkInformation[index]
            }
        }
        return scanTextViewModel
    }
}
