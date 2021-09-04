//
//  CurrencyHistoricalDataNB.swift
//  Accounting
//
//  Created by Roman Topchii on 05.06.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import Foundation

struct CurrencyHistoricalDataNB : Codable, CurrencyHistoricalDataProtocol {
    let exchangeRatesList : [CurrencyExhangeNB]
    
    init(list: [CurrencyExhangeNB]) {
        self.exchangeRatesList = list
    }
   
    
    func exchangeDateStringFormat() -> String? {
        return exchangeRatesList.first?.exchangedate
    }
    
    func ecxhangeDate() -> Date? {
        if exchangeRatesList.isEmpty == false {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            return formatter.date(from: exchangeRatesList.first!.exchangedate)
        }
        return nil
    }
    
    func exchangeRate(curr: String, to curr1: String) -> Double? {
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
                rate = item.rate
            }
            if item.currency == curr1 {
                rate1 = item.rate
            }
        }
        guard let rate11 = rate, let rate21 = rate1 else {return nil}
        return round(rate21/rate11*1000)/1000
    }
    
    func listOfCurrencies() -> [String] {
        var list = [String]()
        exchangeRatesList.forEach({list.append($0.currency)})
        return list
    }
    
    func listOfCurrenciesWithDescription() -> [(String,String)] {
        var list = [(String,String)]()
        exchangeRatesList.forEach({list.append(($0.currency,$0.txt))})
        return list
    }
    
   
}
