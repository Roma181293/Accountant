//
//  Extension Double.swift
//  Accounting
//
//  Created by Roman Topchii on 24.06.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import Foundation

extension Double {
    var formattedWithSeparator: String {
        return Formatter.withSeparator.string(for: self) ?? ""
    }
}
