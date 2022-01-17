//
//  CurrencyHistoricalDataProtocol.swift
//  Accounting
//
//  Created by Roman Topchii on 04.06.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import Foundation

protocol CurrencyHistoricalDataProtocol {
    func exchangeDateStringFormat() -> String?  //dd.MM.yyyy
    func ecxhangeDate() -> Date?
    func exchangeRate(pay: String, forOne curr1 : String) -> Double?
    func listOfCurrencies() -> [String]
    func listOfCurrenciesWithDescription() -> [(String,String)]
    func getRateList() -> [(amount: Double, currencyCode: String)]
    func getBaseCurrencyCode() -> String?  //UAH
//    func getBaseCurrencyISO4217() -> Int16?  //980
}
