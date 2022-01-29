//
//  CurrencyExhangeNB.swift
//  Accounting
//
//  Created by Roman Topchii on 04.06.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import Foundation

struct CurrencyExhangeNB: Codable {
    let code : Int16
    let txt : String
    let rate : Double
    let currency : String
    let exchangedate: String
    
    enum CodingKeys : String, CodingKey {
        case code = "r030"
        case txt
        case rate
        case currency = "cc"
        case exchangedate
    }
}
