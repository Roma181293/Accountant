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
//            guard let dateSafe = formatter.date(from: date) else {return nil}
//            return Calendar.current.startOfDay(for: dateSafe)
            return formatter.date(from: date)
        }
        return nil
    }
    
    func exchangeRate(pay: String, forOne curr1 : String) -> Double? {
        var rate : Double?
        var rate1 : Double?
        if pay == "UAH" {
            rate = 1
        }
        if curr1 == "UAH" {
            rate1 = 1
        }
        for item in self.exchangeRatesList {
            if item.currency == pay {
                rate = item.purchaseRateNB
            }
            if item.currency == curr1 {
                rate1 = item.purchaseRateNB
            }
        }
        guard let rate11 = rate, let rate21 = rate1 else {return nil}
        return round(rate21/rate11*100000)/100000
    }
    
    func listOfCurrencies() -> [String] {
        var list = [String]()
        exchangeRatesList.forEach({
            list.append($0.currency)
        })
        return list
    }
    
    func listOfCurrenciesWithDescription() -> [(String,String)] {
        var list = [(String,String)]()
        exchangeRatesList.forEach({
            list.append(($0.currency,""))
        })
        return list
    }
    
    func getBaseCurrencyCode() -> String? {
        return "UAH"
    }
    
    func getBaseCurrencyISO4217() -> Int16? {
        return Int16(baseCurrency)
    }
    
    func getRateList() -> [(amount: Double, currencyCode: String)] {
        
        var result : [(amount: Double, currencyCode: String)] = []
        
        exchangeRatesList.forEach({
            result.append(($0.purchaseRateNB, $0.currency))
        })
        
        return result
    }
}

