//
//  MigrationPolicy_TransactionItem_V3toV4.swift
//  Accountant
//
//  Created by Roman Topchii on 11.11.2023.
//

import CoreData

// swiftlint:disable all
class MigrationPolicy_TransactionItem_V3toV4: NSEntityMigrationPolicy {
    
    let calendar = Calendar.current
    
    override func createDestinationInstances(forSource sInstance: NSManagedObject,
                                             in mapping: NSEntityMapping,
                                             manager: NSMigrationManager) throws {
        if sInstance.entity.name == "TransactionItem",
           let sAccount = sInstance.value(forKey: "account") as? NSManagedObject,
           let sCurrency = sAccount.value(forKey: "currency") as? NSManagedObject {

            let destResults = manager.destinationInstances(forEntityMappingName: mapping.name,
                                                               sourceInstances: [sInstance])
            
            if (sCurrency.value(forKey: "isAccounting") as? Bool) == true {
                if let destResults = destResults.last {
                    destResults.setValue(sInstance.value(forKey: "amount"), forKey: "amountInAccountingCurrency")
                }
            } else if (sCurrency.value(forKey: "isAccounting") as? Bool) == false {
                guard let sTransaction = sInstance.value(forKey: "transaction") as? NSManagedObject else {return}
                let transactionDate = sTransaction.value(forKey: "date") as! Date
                let transactionDay = Calendar.current.startOfDay(for: transactionDate)
                   
                var rate = (sCurrency.value(forKey: "exchangeRates") as! [NSManagedObject])
                    .first{(rate) -> Bool in
                        var exchange = rate.value(forKey: "exchange") as! NSManagedObject
                        return (exchange.value(forKey: "date") as? Date) == transactionDate
                    }?.value(forKey: "amount") as! Double
                if let destResults = destResults.last {
                    destResults.setValue((sInstance.value(forKey: "amount") as! Double) * rate, forKey: "amountInAccountingCurrency")
                }
            }
        }
    }

    override func performCustomValidation(forMapping mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        throw MigrationError.validationError
    }
}

enum MigrationError: Error {
    case validationError
}
