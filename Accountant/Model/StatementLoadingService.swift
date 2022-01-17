//
//  StatementLoadingService.swift
//  Accountant
//
//  Created by Roman Topchii on 25.12.2021.
//

import Foundation
import CoreData
import Alamofire

class StatementLoadingService {
    
    static func loadStatments(context: NSManagedObjectContext, compliting: @escaping(Bool?, Error?) -> Void) {
        let calendar = Calendar.current
        
        let bankAccounts = BankAccountManager.getBankAccountList(context: context)
        
        for (index, item) in bankAccounts.enumerated() {
         
            let newContext = CoreDataStack.shared.persistentContainer.newBackgroundContext()
            guard let ba = BankAccountManager.getBankAccountByExternalId(item.externalId!, context: newContext) else {return}//
            
            if Date() > calendar.date(byAdding: .second, value: 60, to: ba.lastLoadDate!)! {
                
                ba.locked = true
                ba.lastLoadDate = Date()
                
                do{
                    try newContext.save()
                }
                catch let errorr {
                    print(#function, errorr.localizedDescription)
                }
                
                let startDate = ba.lastTransactionDate!
                var endDate = calendar.date(byAdding: .day, value: 30, to: startDate)!
                if endDate > Date() {
                    endDate = Date()
                }
                
                //                DispatchQueue.main.asyncAfter(deadline: .now() + 60.0*Double(index)) {
                print("--> Loading statments for \(ba.account?.path ?? "")")
                print("item.lastLoadDate, item.lastTransactionDate",ba.lastLoadDate, ba.lastTransactionDate)
                print("startDate, endDate", startDate, endDate)
                
                NetworkServices.loadStatementsForBankAccount(ba,startDate: startDate, endDate: endDate, compliting: {statments, error in
                    print("--> Statements successfully loaded for \(ba.account?.path ?? "")", ba.externalId)
                    if let statments = statments {
                        // print("statments.count",statments.count)
                        do{
                            var transactions : [Transaction]  = []
                            statments.forEach({
                                transactions.append(TransactionManager.addTransactionDraft(account: ba.account!, statment: $0, context: newContext))
                            })
                            ba.lastTransactionDate = endDate
                            try newContext.save()
                            compliting(true, nil)
                        }
                        catch let errorr {
                            print(#function, errorr.localizedDescription)
                            compliting(nil,errorr)
                        }
                        
                    }
                    else if let error = error {
                        print(#function, error.localizedDescription)
                        compliting(nil,error)
                    }
                    ba.locked = false
                    ba.lastLoadDate = Date()
                })
                //                }
            }
            else {
                print("--> There is no need to get statments", ba.lastLoadDate!)
                compliting(nil,MonoBankError.toEarlyToRetrieveTheData(date: ba.lastLoadDate!))
            }
        }
    }
}
