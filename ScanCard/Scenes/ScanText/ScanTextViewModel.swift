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

    func checkValidInfo(cardInfo: Card, completion: (Result) -> Void) {

        // Check valid Name
        if !isValidCardHolder(cardHolder: cardInfo.cardHolder ?? "") {
            completion(.invalidCardHolder)
            return
        }

        // Check valid bank number
        if !isValidCardNumber(cardNumber: cardInfo.cardNumber ?? "") {
            completion(.invalidCardNumber)
            return
        }

        // check valid created date
        if !isValidIssueDate(checkIssueDate: cardInfo.issueDate ?? "") {
            completion(.invalidIssueDate)
            return
        }

        // check valid validate date
        if !isValidExpiryDate(checkExpiryDate: cardInfo.expiryDate ?? "") {
            completion(.invalidExpiryDate)
            return
        }
        completion(.success)
    }

    func isValidCardNumber(cardNumber: String) -> Bool {
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

    func isValidCardHolder(cardHolder: String) -> Bool {
        if !cardHolder.isOnlyUpCaseAndWhiteSpaceCharacter { return false }
        let nameAfterCutWhiteSpacesAndNewlines = cardHolder.components(separatedBy: .whitespacesAndNewlines)
            .filter({ !$0.isEmpty })
            .joined(separator: " ")
        return nameAfterCutWhiteSpacesAndNewlines.contains(" ")
        }

    func isValidIssueDate(checkIssueDate: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/yy"
        let inputDate = dateFormatter.date(from: checkIssueDate)
        guard let checkInputDate = inputDate else {
            return false }
        return checkInputDate < Date()
    }

    func isValidExpiryDate(checkExpiryDate: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/yy"
        let inputDate = dateFormatter.date(from: checkExpiryDate)
        guard let checkInputDate = inputDate else { return false }
        return checkInputDate > Date()
    }
}
