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
                compliting(nil, ServiceError.toEarlyToRetrieveTheData(date: bankAccount.lastLoadDate!))
            }
        }
    }

    enum ServiceError: AppError {
        case toEarlyToRetrieveTheData(date: Date)
    }
}

extension StatementsLoadingService.ServiceError: LocalizedError {
    private func formateDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .medium
        dateFormatter.locale = Locale(identifier: "\(Bundle.main.localizations.first ?? "en")_" +
                                      "\(Locale.current.regionCode ?? "US")")
        return dateFormatter.string(from: date)
    }

    private func getMonoLink() -> String {
        return "https://api.monobank.ua/docs"
    }

    public var errorDescription: String? {
        switch self {
        case let .toEarlyToRetrieveTheData(date):
            return String(format: NSLocalizedString("Too early to retrive Monobank statements data. Please wait 1 " +
                                                    "minute to the next try. This limitation was imposed due to " +
                                                    "API policy %@ \n\nLast load %@ \nCurrent call %@", comment: ""),
                          getMonoLink(), formateDate(date), formateDate(Date()))
        }
    }
}
