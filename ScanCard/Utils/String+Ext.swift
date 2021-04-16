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
}
