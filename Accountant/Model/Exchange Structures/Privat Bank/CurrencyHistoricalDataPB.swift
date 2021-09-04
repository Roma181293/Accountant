//
//  CurrencyHistoricalData.swift
//  Accounting
//
//  Created by Roman Topchii on 22.04.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import Foundation

struct CurrencyHistoricalDataPB: Codable, CurrencyHistoricalDataProtocol {
    let date : String
    let bank : String
    let baseCurrency : Int
    let baseCurrencyLit : String
    let exchangeRatesList : [CurrencyExchangePB]
    
    enum CodingKeys : String, CodingKey {
        case date
        case bank
        case baseCurrency
        case baseCurrencyLit
        case exchangeRatesList = "exchangeRate"
    }
    
    func exchangeDateStringFormat() -> String? {
        return date
    }
    
    func ecxhangeDate() -> Date? {
        if exchangeRatesList.isEmpty == false {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            return formatter.date(from: date)
        }
        return nil
    }
    
    func exchangeRate(curr: String, to curr1 : String) -> Double? {
        var rate : Double?
        var rate1 : Double?
        if curr == "UAH" {
            rate = 1
        }
        if curr1 == "UAH" {
            rate1 = 1
        }
        for item in self.exchangeRatesList {
            if item.currency == curr {
                rate = item.purchaseRateNB
            }
            if item.currency == curr1 {
                rate1 = item.purchaseRateNB
            }
        }
        guard let rate11 = rate, let rate21 = rate1 else {return nil}
        return round(rate21/rate11*1000)/1000
    }
    
    func listOfCurrencies() -> [String] {
        var list = [String]()
        exchangeRatesList.forEach({
            if let currency = $0.currency {
                list.append(currency)}
        })
        return list
    }
    
    func listOfCurrenciesWithDescription() -> [(String,String)] {
        var list = [(String,String)]()
        exchangeRatesList.forEach({
            if let currency = $0.currency {
                list.append((currency,""))}
        })
        return list
    }
}

