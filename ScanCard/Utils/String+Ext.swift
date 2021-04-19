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

    var isContainNumberic: Bool {
        let decimalCharacters = CharacterSet.decimalDigits
        let decimalRange = self.rangeOfCharacter(from: decimalCharacters)
        return !(self.isEmpty) && decimalRange != nil
    }
}
