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
    case invalidName
    case invalidBank
    case invalidCreatedDate
    case invalidValidDate
}

class ScanTextViewModel {

    var userInfo: UserInfoModel?
    let maxCardNumber = 19
    let minCardNumber = 16

    init(userInfor: UserInfoModel) {
        self.userInfo = userInfor
    }

    func checkValidInfo(userInfo: UserInfoModel, completion: (Result) -> Void) {

        // Check valid Name
        if !isValidName(name: userInfo.name ?? "") {
            completion(.invalidName)
            return
        }

        // Check valid bank number
        if !isValidNumberBank(banknumber: userInfo.bankNumber ?? "") {
            completion(.invalidBank)
            return
        }

        // check valid created date
        if !isValidCreatedDate(checkDate: userInfo.createdDate ?? "") {
            completion(.invalidCreatedDate)
            return
        }

        // check valid validate date
        if !isValidValidateDate(checkDate: userInfo.validDate ?? "") {
            completion(.invalidValidDate)
            return
        }
        completion(.success)
    }

    func isValidNumberBank(banknumber: String) -> Bool {
        let vowels: Set<Character> = [" "]
        var tmpString = ""
        tmpString = banknumber
        tmpString.removeAll(where: { vowels.contains($0) })

        if !tmpString.isNumeric {
            return false
        }

        if tmpString.count<minCardNumber || tmpString.count>maxCardNumber {
            print("incorrect format")
            return false
        }
        print("correct fromat")
        return true
    }

    func isValidName(name: String) -> Bool {
        if !name.isOnlyUpCaseAndWhiteSpaceCharacter { return false }
        let nameAfterCutwhiteSpacesAndNewlines = name.components(separatedBy: .whitespacesAndNewlines)
            .filter({ !$0.isEmpty })
            .joined(separator: " ")
        return nameAfterCutwhiteSpacesAndNewlines.contains(" ")
    }

    func isValidCreatedDate(checkDate: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/yy"
        let inputDate = dateFormatter.date(from: checkDate)
        guard let checkInputDate = inputDate else { return false }
        return checkInputDate < Date()
    }

    func isValidValidateDate(checkDate: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/yy"
        let inputDate = dateFormatter.date(from: checkDate)
        guard let checkInputDate = inputDate else { return false }
        return checkInputDate > Date()
    }
}
