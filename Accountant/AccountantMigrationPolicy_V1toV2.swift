//
//  AccountantMigrationPolicy_V1toV2.swift
//  Accountant
//
//  Created by Roman Topchii on 17.01.2022.
//

import Foundation
import CoreData

class AccountantMigrationPolicy_V1toV2: NSEntityMigrationPolicy {
    override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        
        try super.createDestinationInstances(forSource: sInstance, in: mapping, manager: manager)
        
        
        if sInstance.entity.name == "Account" {
           let destResults = manager.destinationInstances(forEntityMappingName: mapping.name, sourceInstances: [sInstance])
            if let destResults = destResults.last {
                destResults.setValue(UUID(), forKey: "id")
                destResults.setValue(false, forKey: "modifiedByUser")
                destResults.setValue(Date(), forKey: "modifyDate")
            }
        }
        else if sInstance.entity.name == "Currency" {
            let currencyCodeMapping = [(code: "UAH", iso4217: 980), (code: "AUD", iso4217: 36), (code: "CAD", iso4217: 124), (code: "CNY", iso4217: 156), (code: "HRK", iso4217: 191), (code: "CZK", iso4217: 203), (code: "DKK", iso4217: 208), (code: "HKD", iso4217: 344), (code: "HUF", iso4217: 348), (code: "INR", iso4217: 356), (code: "IDR", iso4217: 360), (code: "ILS", iso4217: 376), (code: "JPY", iso4217: 392), (code: "KZT", iso4217: 398), (code: "KRW", iso4217: 410), (code: "MXN", iso4217: 484), (code: "MDL", iso4217: 498), (code: "NZD", iso4217: 554), (code: "NOK", iso4217: 578), (code: "RUB", iso4217: 643), (code: "SAR", iso4217: 682), (code: "SGD", iso4217: 702), (code: "ZAR", iso4217: 710), (code: "SEK", iso4217: 752), (code: "CHF", iso4217: 756), (code: "EGP", iso4217: 818), (code: "GBP", iso4217: 826), (code: "USD", iso4217: 840), (code: "BYN", iso4217: 933), (code: "RON", iso4217: 946), (code: "TRY", iso4217: 949), (code: "BGN", iso4217: 975), (code: "EUR", iso4217: 978), (code: "PLN", iso4217: 985), (code: "DZD", iso4217: 12), (code: "BDT", iso4217: 50), (code: "AMD", iso4217: 51), (code: "IRR", iso4217: 364), (code: "IQD", iso4217: 368), (code: "KGS", iso4217: 417), (code: "LBP", iso4217: 422), (code: "LYD", iso4217: 434), (code: "MYR", iso4217: 458), (code: "MAD", iso4217: 504), (code: "PKR", iso4217: 586), (code: "VND", iso4217: 704), (code: "THB", iso4217: 764), (code: "AED", iso4217: 784), (code: "TND", iso4217: 788), (code: "UZS", iso4217: 860), (code: "TMT", iso4217: 934), (code: "RSD", iso4217: 941), (code: "AZN", iso4217: 944), (code: "TJS", iso4217: 972), (code: "GEL", iso4217: 981), (code: "BRL", iso4217: 986)]

            currencyCodeMapping.forEach({
                
                let destResults = manager.destinationInstances(forEntityMappingName: mapping.name, sourceInstances: [sInstance])
                 if let destResults = destResults.last {
                     
                     if (sInstance.primitiveValue(forKey: "code") as! String) == $0.code {
                         destResults.setValue($0.iso4217, forKey: "iso4217")
                     }
                     destResults.setValue(UUID(), forKey: "id")
                     destResults.setValue(false, forKey: "modifiedByUser")
                     destResults.setValue(Date(), forKey: "modifyDate")
                 }
            })

        }
        else if sInstance.entity.name == "Transaction" {
            let destResults = manager.destinationInstances(forEntityMappingName: mapping.name, sourceInstances: [sInstance])
             if let destResults = destResults.last {
                 destResults.setValue(UUID(), forKey: "id")
                 destResults.setValue(true, forKey: "applied")
                 destResults.setValue(false, forKey: "modifiedByUser")
                 destResults.setValue(Date(), forKey: "modifyDate")
             }
            
        }
        else if sInstance.entity.name == "TransactionItem" {
            let destResults = manager.destinationInstances(forEntityMappingName: mapping.name, sourceInstances: [sInstance])
             if let destResults = destResults.last {
                 destResults.setValue(UUID(), forKey: "id")
                 destResults.setValue(false, forKey: "modifiedByUser")
                 destResults.setValue(Date(), forKey: "modifyDate")
             }
        }
    }
}

