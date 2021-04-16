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
    case invalidname
    case invalidbank
    case invalidcreateddate
    case invalidvaliddate
}

class ScanTextViewModel {

    var userInfo: UserInfoModel?
    let maxCardNumber = 19
    let minCardNumber = 16

    init(userInfor: UserInfoModel) {
        self.userInfo = userInfor
    }

    func checkValidInfo(userInfo:UserInfoModel, completion:(Result) -> Void) {
        if !checkvalidNumberBank(banknumber: userInfo.bankNumber ?? "") {
            completion(.invalidbank)
        }
        print("")
    }

    func checkvalidNumberBank(banknumber:String) -> Bool {
        let vowels: Set<Character> = [" "]
        var tmpString = ""
        tmpString = banknumber
        tmpString.removeAll(where: { vowels.contains($0) })

        if !tmpString.isNumeric {
            return false
        }

        if (tmpString.count<minCardNumber || tmpString.count>maxCardNumber) {
            print("incorrect format")
            return false
        }
        print("correct fromat")
        return true
    }
}
