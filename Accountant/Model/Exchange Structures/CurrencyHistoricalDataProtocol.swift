//
//  CurrencyHistoricalDataProtocol.swift
//  Accounting
//
//  Created by Roman Topchii on 04.06.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import Foundation

protocol CurrencyHistoricalDataProtocol {
    func exchangeDate() -> String?  //dd.MM.yyyy
    func ecxhangeDate() -> Date?
    func exchangeRate(curr: String, to curr1 : String) -> Double?
    func listOfCurrencies() -> [String]
    func listOfCurrenciesWithDescription() -> [(String,String)]
}
