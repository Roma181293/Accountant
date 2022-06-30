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

    class func loadCurrency(date: Date, compliting: @escaping (CurrencyHistoricalDataProtocol?, Error?) -> Void) {
        loadCurrencyNB(date: date) { (currencyHistoricalData, _) in
            if let currencyHistoricalData = currencyHistoricalData {
                compliting(currencyHistoricalData, nil)
            } else {
                loadCurrencyPB(date: date) { (currencyHistoricalData, error) in
                    compliting(currencyHistoricalData, error)
                }
            }
        }
    }

    private class func loadCurrencyPB(date: Date, compliting: @escaping (CurrencyHistoricalDataPB?, Error?) -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let dateString = dateFormatter.string(from: date as Date)
        print(#function, dateString)
        AF.request("https://api.privatbank.ua/p24api/exchange_rates?json&date=\(dateString)")
            .responseDecodable(of: CurrencyHistoricalDataPB.self) {(response) in
                if let currencyHistoricalData = response.value {
                    compliting(currencyHistoricalData, nil)
                } else {
                    print("ERROR: \(String(describing: response.error?.localizedDescription))")
                    compliting(nil, response.error)
                }
            }
    }

    private class func loadCurrencyNB(date: Date, compliting: @escaping (CurrencyHistoricalDataNB?, Error?) -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let dateString = dateFormatter.string(from: date as Date)
        print(#function, dateString)
        AF.request("https://bank.gov.ua/NBUStatService/v1/statdirectory/exchange?date=\(dateString)&json")
            .responseDecodable(of: [CurrencyExhangeNB].self) {(response) in
                if let list = response.value {
                    print(#function, CurrencyHistoricalDataNB(list: list).listOfCurrenciesIso())
                    compliting(CurrencyHistoricalDataNB(list: list), nil)
                } else {
                    print("ERROR: \(String(describing: response.error?.localizedDescription))")
                    compliting(nil, response.error)
                }
            }
    }

    class func loadMBUserInfo(xToken: String, compliting: @escaping (MBUserInfo?, String?, Error?) -> Void) {
        AF.request("https://api.monobank.ua/personal/client-info",
                   headers: ["X-Token": xToken]
        ).responseDecodable(of: MBUserInfo.self) {(response) in
            if let list = response.value {
                compliting(list, xToken, nil)
            } else {
                print("ERROR: \(String(describing: response.error?.localizedDescription))")
                compliting(nil, nil, response.error)
            }
        }
    }

    class func loadStatementsForBankAccount(_ bankAccount: BankAccount, startDate: Date, endDate: Date,
                                            compliting: @escaping ([StatementProtocol]?, Error?) -> Void) {
        if bankAccount.userBankProfile?.keeper?.name == "Monobank" {

            AF.request("https://api.monobank.ua/personal/statement/\(bankAccount.externalId!)/\(Int(startDate.timeIntervalSince1970))/\(Int(endDate.timeIntervalSince1970))", // swiftlint:disable:this line_length
                       headers: ["X-Token": bankAccount.userBankProfile!.xToken!]
            ).responseDecodable(of: [MBStatement].self) {(response) in
                if let list = response.value {
                    compliting(list, nil)
                } else {
                    print("ERROR: \(String(describing: response.error?.localizedDescription))")
                    compliting(nil, response.error)
                }
            }
        }
    }
}
