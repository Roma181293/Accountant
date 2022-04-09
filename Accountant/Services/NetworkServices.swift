//
//  NetworkServices.swift
//  Accounting
//
//  Created by Roman Topchii on 13.04.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import Foundation
import Alamofire
import CoreData

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
    
    private static func loadCurrencyPB(date : Date, compliting: @escaping (CurrencyHistoricalDataPB?, Error?) -> Void){
        
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
    
    private static func loadCurrencyNB(date : Date, compliting: @escaping (CurrencyHistoricalDataNB?, Error?) -> Void){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let dateString = dateFormatter.string(from:date as Date)
        print(#function, dateString)
        AF.request("https://bank.gov.ua/NBUStatService/v1/statdirectory/exchange?date=\(dateString)&json").responseDecodable(of: [CurrencyExhangeNB].self) {(response) in
            if let list = response.value {
                print(#function,CurrencyHistoricalDataNB(list: list).listOfCurrenciesIso())
                compliting(CurrencyHistoricalDataNB(list: list), nil)
            }
            else {
                print("ERROR: \(String(describing: response.error?.localizedDescription))")
                compliting(nil, response.error)
            }
        }
    }
    
    
    static func loadMBUserInfo(xToken: String, compliting: @escaping (MBUserInfo?, String?, Error?) -> Void){
        AF.request("https://api.monobank.ua/personal/client-info",
                   headers: ["X-Token" : xToken]
        ).responseDecodable(of: MBUserInfo.self) {(response) in
            if let list = response.value {
                compliting(list, xToken, nil)
            }
            else {
                print("ERROR: \(String(describing: response.error?.localizedDescription))")
                compliting(nil, nil, response.error)
            }
        }
    }

    static func loadStatementsForBankAccount(_ bankAccount: BankAccount, startDate: Date, endDate: Date, compliting: @escaping ([StatementProtocol]?, Error?) -> Void){
     
        if bankAccount.userBankProfile?.keeper?.name == "Monobank" {
            print("bankAccount.userBankProfile!.xToken!", bankAccount.userBankProfile!.xToken!, "https://api.monobank.ua/personal/statement/\(bankAccount.externalId!)/\(Int(startDate.timeIntervalSince1970))/\(Int(endDate.timeIntervalSince1970))")
            AF.request("https://api.monobank.ua/personal/statement/\(bankAccount.externalId!)/\(Int(startDate.timeIntervalSince1970))/\(Int(endDate.timeIntervalSince1970))",
                       headers: ["X-Token" : bankAccount.userBankProfile!.xToken!]
            ).responseDecodable(of: [MBStatement].self) {(response) in
                if let list = response.value {
                    compliting(list, nil)
                }
                else {
                    print("ERROR: \(String(describing: response.error?.localizedDescription))")
                    compliting(nil, response.error)
                }
            }
        }
    }
    
    
    //MARK: - Methods below only for test purpose
    private static func loadStatementsForBankAccountWOParse(_ bankAccount: BankAccount, compliting: @escaping ([StatementProtocol]?, Error?) -> Void){
     
        if bankAccount.userBankProfile?.keeper?.name == "Monobank" {
            let calendar = Calendar.current
            
            let startDate = bankAccount.lastTransactionDate!
            var endDate = calendar.date(byAdding: .day, value: 30, to: startDate)!
            if endDate > Date() {
                endDate = Date()
            }
            print(#function, "https://api.monobank.ua/personal/statement/\(bankAccount.id!)/\(Int(startDate.timeIntervalSince1970))/\(Int(endDate.timeIntervalSince1970))")
            AF.request("https://api.monobank.ua/personal/statement/\(bankAccount.id!)/\(Int(startDate.timeIntervalSince1970))/\(Int(endDate.timeIntervalSince1970))",
                       headers: ["X-Token" : bankAccount.userBankProfile!.xToken!]
            ).responseJSON(completionHandler: { response in
                switch response.result {
                case .success(let value):
                    print("value**: \(value)")
                    
                case .failure(let error):
                    print(error)
                }
            })
            .responseString { response in
                print("response: \(response)")
                switch response.result {
                case .success(let value):
                    print("value**: \(value)")
                    
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    private static func loadStatements(compliting: @escaping ([MBStatement]?, Error?) -> Void){
     
        AF.request("https://api.monobank.ua/personal/statement/0/1635717600/1637212479187",
                   headers: ["X-Token" : ""]
        ).responseDecodable(of: [MBStatement].self) {(response) in
            if let list = response.value {
                compliting(list, nil)
            }
            else {
                print("ERROR: \(String(describing: response.error?.localizedDescription))")
                compliting(nil, response.error)
            }
        }
    }
    
    
    private static func loadWebHook(compliting: @escaping (MBWebHook?, Error?) -> Void){
     
        AF.request("https://api.monobank.ua/personal/webhook",
                   method:.post,
                   headers: ["X-Token" : ""]
        ).responseDecodable(of: MBWebHook.self) {(response) in
            if let list = response.value {
                print(#function,list)
                
                
                compliting(list, nil)
            }
            else {
                print(#function,"ERROR: \(String(describing: response.error?.localizedDescription))")
                compliting(nil, response.error)
            }
        }
    }
    
    
    private static func loadWebHook1(){
     
        AF.request("https://api.monobank.ua/personal/webhook",
                   method:.post,
                   headers: ["X-Token" : ""]
        ).responseJSON { response in
            print("response: \(response)")
            switch response.result {
            case .success(let value):
                print("value**: \(value)")
                
            case .failure(let error):
                print(error)
            }
    }
    .responseString { response in
        print("response: \(response)")
        switch response.result {
        case .success(let value):
            print("value**: \(value)")
            
        case .failure(let error):
            print(error)
        }
    }
    }
}
