//
//  CurrencyExchange.swift
//  Accounting
//
//  Created by Roman Topchii on 22.04.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import Foundation

struct CurrencyExchangePB : Codable {
    let baseCurrency : String
    let currency : String
    let saleRateNB : Double
    let purchaseRateNB : Double
    
    enum CodingKeys : String, CodingKey {
        case baseCurrency
        case currency
        case saleRateNB
        case purchaseRateNB
    }
}
