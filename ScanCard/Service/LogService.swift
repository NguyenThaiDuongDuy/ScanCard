//
//  LogService.swift
//  ScanCard
//
//  Created by admin on 07/04/2021.
//

import Foundation


class LogService {
    
    static let share = LogService()
    var debug:Bool = false
    
    
    func print() {
        if debug {
            print()
        } else {
            return
        }
    }
}
