//
//  StatementsLoadingService.swift
//  Accountant
//
//  Created by Roman Topchii on 25.12.2021.
//

import Foundation
import CoreData
import Alamofire

class StatementsLoadingService {
    class func loadStatments(context: NSManagedObjectContext, compliting: @escaping(Bool?, Error?) -> Void) {
        let calendar = Calendar.current

        let bankAccounts = BankAccountHelper.getBankAccountList(context: context)
        for item in bankAccounts {
            let newContext = CoreDataStack.shared.persistentContainer.newBackgroundContext()
            guard let bankAccount = BankAccountHelper.getBankAccountByExternalId(item.externalId!, context: newContext)
            else {return}

            guard bankAccount.active == true else {return}

            if Date() > calendar.date(byAdding: .second, value: 60, to: bankAccount.lastLoadDate!)! {

                bankAccount.locked = true
//                bankAccount.lastLoadDate = Date()
                do {
                    try newContext.save()
                } catch let errorr {
                    print(#function, errorr.localizedDescription)
                }

                let startDate = bankAccount.lastTransactionDate!
                var endDate = calendar.date(byAdding: .day, value: 30, to: startDate)!
                if endDate > Date() {
                    endDate = Date()
                }

                NetworkServices.loadStatementsForBankAccount(bankAccount, startDate: startDate, endDate: endDate,
                                                             compliting: {statments, error in
                    if let statments = statments {
                        do {
                            var transactions: [Transaction]  = []
                            statments.forEach({
                                transactions.append(TransactionHelper.addTransactionDraft(account: bankAccount.account!,
                                                                                    statment: $0, context: newContext))
                            })
                            bankAccount.lastTransactionDate = endDate
                            bankAccount.locked = false
                            bankAccount.lastLoadDate = Date()
                            try newContext.save()
                            compliting(true, nil)
                        } catch let errorr {
                            compliting(nil, errorr)
                        }
                    } else if let error = error {
                        print(#function, error.localizedDescription)
                        compliting(nil, error)
                    }
                    bankAccount.locked = false
                    bankAccount.lastLoadDate = Date()
                })
            } else {
                compliting(nil, MonoBankError.toEarlyToRetrieveTheData(date: bankAccount.lastLoadDate!))
            }
        }
    }
}
