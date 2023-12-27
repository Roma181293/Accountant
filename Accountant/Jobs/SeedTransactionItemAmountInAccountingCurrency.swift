//
//  SeedTransactionItemAmountInAccountingCurrency.swift
//  Accountant
//
//  Created by Roman Topchii on 27.12.2023.
//

import Foundation

class SeedTransactionItemAmountInAccountingCurrency {
    
    class func execute() {
        
        //Check if the job already executed
        
        var context = CoreDataStack.shared.persistentContainer.viewContext
        
        let request = Transaction.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "\(Schema.Transaction.createDate)", ascending: true)]
        let transactions = try? context.fetch(request)
        
        transactions?.forEach({ transaction in
            transaction.items.forEach({ item in
                if item.account?.currency?.isAccounting == true {
                    item.amountInAccountingCurrency = item.amount
                } else if item.account?.currency?.isAccounting == false {
                    let transactionDay = Calendar.current.startOfDay(for: transaction.date)
                    let rate = item.account?.currency?.exchangeRates.first{ $0.exchange?.date == transactionDay}?.amount as? Double

                    if let rate = rate {
                        item.amountInAccountingCurrency = item.amount * rate
                    } else {
                        item.amountInAccountingCurrency = item.amount
                        item.transaction?.comment = (item.transaction?.comment ?? "") + "Need review amounts"
                    }
                }
            })
        })
        try? context.save()
        
        //Mark that the job already executed
    }
}
