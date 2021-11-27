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
    
    
    static func loadMBUserInfo(compliting: @escaping (MBUserInfo?, Error?) -> Void){
     
        AF.request("https://api.monobank.ua/personal/client-info",
                   headers: ["X-Token" : "uHSislDn_PZokeUPUiigOU6tBaM2Ub95T0Qekafe069I"]
        ).responseDecodable(of: MBUserInfo.self) {(response) in
            if let list = response.value {
                compliting(list, nil)
            }
            else {
                print("ERROR: \(String(describing: response.error?.localizedDescription))")
                compliting(nil, response.error)
            }
        }
    }
    
    static func loadMBUserInfo(){
     
        AF.request("https://api.monobank.ua/personal/client-info",
                   headers: ["X-Token" : "uHSislDn_PZokeUPUiigOU6tBaM2Ub95T0Qekafe069I"]
        ).response{(response) in
            if let error = response.error {
                print("ERROR: \(String(describing: error.localizedDescription))")
            }
            else {
                print(response.value as? String)
            }
        }
    }
}




struct MBUserInfo:Codable {
    let clientId : String
    let name : String
    let webHookUrl: String
    let permissions: String
    let accounts: [MBAccountInfo]
}


struct MBAccountInfo: Codable {
    let id : String
    let sendId: String
    let balance : Int
    let creditLimit : Int
    let type : String
    let maskedPan : [String]
    let currencyCode: Int
    let cashbackType: String
}
