//
//  NetworkServices.swift
//  Accounting
//
//  Created by Roman Topchii on 13.04.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import Foundation
import Alamofire

class NetworkServices {
    
    static func loadCurrency(date : Date, compliting: @escaping (CurrencyHistoricalDataProtocol?, Error?) -> Void){
        loadCurrencyNB(date: date) { (currencyHistoricalData, error) in
            if let currencyHistoricalData = currencyHistoricalData{
                compliting(currencyHistoricalData, nil)
            }
            else {
                loadCurrencyPB(date: date) { (currencyHistoricalData, error) in
                    compliting(currencyHistoricalData, nil)
                }
            }
        }
    }
    
    static func loadCurrencyPB(date : Date, compliting: @escaping (CurrencyHistoricalDataPB?, Error?) -> Void){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let dateString = dateFormatter.string(from:date as Date)
        print(#function, dateString)
        AF.request("https://api.privatbank.ua/p24api/exchange_rates?json&date=\(dateString)").responseDecodable(of: CurrencyHistoricalDataPB.self) {(response) in
            if let currencyHistoricalData = response.value {
                compliting(currencyHistoricalData, nil)
            }
            else {
                print("ERROR: \(String(describing: response.error?.localizedDescription))")
                compliting(nil, response.error)
            }
        }
    }
    
    static func loadCurrencyNB(date : Date, compliting: @escaping (CurrencyHistoricalDataNB?, Error?) -> Void){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let dateString = dateFormatter.string(from:date as Date)
        print(#function, dateString)
        AF.request("https://bank.gov.ua/NBUStatService/v1/statdirectory/exchange?date=\(dateString)&json").responseDecodable(of: [CurrencyExhangeNB].self) {(response) in
            if let list = response.value {
                compliting(CurrencyHistoricalDataNB(list: list), nil)
            }
            else {
                print("ERROR: \(String(describing: response.error?.localizedDescription))")
                compliting(nil, response.error)
            }
        }
    }
}
