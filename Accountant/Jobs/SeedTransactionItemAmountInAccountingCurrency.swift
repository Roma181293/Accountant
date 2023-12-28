//
//  SeedTransactionItemAmountInAccountingCurrency.swift
//  Accountant
//
//  Created by Roman Topchii on 27.12.2023.
//

import Foundation

class SeedTransactionItemAmountInAccountingCurrency {
    class func execute() {
        do {
            guard !UserProfileService.isSeedTransactionItemAmountInAccountingCurrencyJobExecuted() else {return}
            let context = CoreDataStack.shared.persistentContainer.viewContext
            let request = TransactionItem.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "\(Schema.TransactionItem.createDate)", ascending: true)]
            try context
                .fetch(request)
                .filter({$0.transaction != nil})
                .forEach({ item in
                    if item.account?.currency?.isAccounting == true {
                        item.amountInAccountingCurrency = item.amount
                    } else if item.account?.currency?.isAccounting == false {
                        let transactionDay = Calendar.current.startOfDay(for: item.transaction!.date)
                        if let rate = item.account?.currency?.exchangeRates
                            .first(where: {$0.exchange?.date == transactionDay})?.amount as? Double {
                            item.amountInAccountingCurrency = round(item.amount * rate * 100) / 100
                        } else {
                            item.amountInAccountingCurrency = item.amount
                            item.transaction?.comment = (item.transaction?.comment ?? "") + "Need review amounts"
                        }
                    }
                })
            try CoreDataStack.shared.saveContext(context)
            UserProfileService.setSeedTransactionItemAmountInAccountingCurrencyJobExecuted()
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
