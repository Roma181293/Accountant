//
//  ExchangeRatesLoadingService.swift
//  Accountant
//
//  Created by Roman Topchii on 12.01.2022.
//

import Foundation
import CoreData

class ExchangeRatesLoadingService {
    
    static func loadExchangeRates(context: NSManagedObjectContext) {
        
        var lastExchangeDate: Date = Calendar.current.date(byAdding: .day, value: -10, to: Date())!
        
        if let lastExchangeDateUnwraped = ExchangeManager.lastExchangeDate(context: context) {
            lastExchangeDate = lastExchangeDateUnwraped
        }
        
        var exchangeDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: lastExchangeDate)!
//        print("exchangeDate [0] ", exchangeDate)
        while exchangeDate <= Calendar.current.startOfDay(for: Date()) {
//            print(#function, "exchangeDate", exchangeDate)
            NetworkServices.loadCurrency(date: exchangeDate, compliting: { (currencyHistoricalData, error) in
                if let currencyHistoricalData = currencyHistoricalData {
                    do {
                        let backgroundContext = CoreDataStack.shared.persistentContainer.newBackgroundContext()
                        
                        ExchangeManager.createExchangeRatesFrom(currencyHistoricalData: currencyHistoricalData, context: backgroundContext)
                        try backgroundContext.save()
                    }
                    catch let error{
                        print(error.localizedDescription)
                    }
                }
            })
            exchangeDate = Calendar.current.date(byAdding: .day, value: 1, to: exchangeDate)!
        }
    }
}
