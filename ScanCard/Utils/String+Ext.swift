//
//  String+Ext.swift
//  ScanCard
//
//  Created by admin on 16/04/2021.
//

import Foundation
extension String {
    var isNumeric: Bool {
        !(self.isEmpty) && self.allSatisfy { $0.isNumber }
    }

    var isOnlyUpCaseAndWhiteSpaceCharacter: Bool {
        let characterset = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZ ")
        if self.rangeOfCharacter(from: characterset.inverted) != nil {
            return false
        } else {
            return true
        }
    }
}
