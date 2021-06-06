//
//  Extension Formatter.swift
//  Accounting
//
//  Created by Roman Topchii on 24.06.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import Foundation


extension Formatter {
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = " "
        formatter.numberStyle = .decimal
      
//        formatter.numberStyle = .currencyISOCode
//        formatter.currencyCode = "USD"
        return formatter
    }()
}
