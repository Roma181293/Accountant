//
//  ImportExportAccountWorker.swift
//  Accountant
//
//  Created by Roman Topchii on 01.07.2022.
//

import Foundation
import CoreData

class ImportExportAccountWorker {
    class func exportAccountsToString(context: NSManagedObjectContext) -> String {
        /*
         let accountFetchRequest: NSFetchRequest<Account> = fetchRequest()
         let sortDescroptors = [NSSortDescriptor(key: "\(Schema.Account.parent.rawValue).\(Schema.Account.name.rawValue)", ascending: true),
         NSSortDescriptor(key: Schema.Account.name.rawValue, ascending: true)]
         accountFetchRequest.sortDescriptors = sortDescroptors
         do {
         let storedAccounts = try context.fetch(accountFetchRequest)
         var export: String = "ParentAccount_path,Account_name,active,Account_type,Account_currency,Account_SubType,LinkedAccount_path\n"
         for account in storedAccounts {

         var accountType = ""
         switch account.type {
         case TypeEnum.assets:
         accountType = "Assets"
         case TypeEnum.liabilities:
         accountType = "Liabilities"
         default:
         accountType = "Out of enumeration"
         }

         var accountSubType = ""
         switch account.subType {
         case SubTypeEnum.none:
         accountSubType = ""
         case SubTypeEnum.cash:
         accountSubType = "Cash"
         case SubTypeEnum.debitCard:
         accountSubType = "DebitCard"
         case SubTypeEnum.creditCard:
         accountSubType = "CreditCard"
         default:
         accountSubType = "Out of enumeration"
         }

         export +=  "\(account.parent != nil ? account.parent!.path : "" ),"
         export +=  "\(account.name),"
         export +=  "\(account.active),"
         export +=  "\(accountType),"
         export +=  "\(account.currency?.code ?? "MULTICURRENCY"),"
         export +=  "\(accountSubType),"
         export +=  "\(account.linkedAccount != nil ? account.linkedAccount!.path: "" )\n"
         }
         return export
         } catch let error {
         print("ERROR", error)
         */
        return ""
        //        }
    }

    class func importAccounts(_ data: String, context: NSManagedObjectContext) throws { // swiftlint:disable:this cyclomatic_complexity function_body_length
        /*
         var accountToBeAdded: [Account] = []
         var inputMatrix: [[String]] = []
         let rows = data.components(separatedBy: "\n")
         for row in rows {
         let columns = row.components(separatedBy: ",")
         inputMatrix.append(columns)
         }
         inputMatrix.remove(at: 0)

         for row in inputMatrix {
         guard row.count > 1 else {break}

         let parent = AccountHelper.getAccountWithPath(row[0], context: context)

         let name = String(row[1])

         var active = false
         switch row[2] {
         case "false":
         active = false
         case "true":
         active = true
         default:
         break // throw ImportAccountError.invalidactiveValue
         }

         var accountType: Int16 = 0
         switch row[3] {
         case "Assets":
         accountType = TypeEnum.assets.rawValue
         case "Liabilities":
         accountType = TypeEnum.liabilities.rawValue
         default:
         break // throw ImportAccountError.invalidAccountTypeValue
         }

         let curency = try? Currency.getCurrencyForCode(row[4], context: context)

         var accountSubType: Int16 = 0
         switch row[5] {
         case "":
         accountSubType = 0
         case "Cash":
         accountSubType = 1
         case "DebitCard":
         accountSubType = 2
         case "CreditCard":
         accountSubType = 3
         default:
         break // throw ImportAccountError.invalidAccountSubTypeValue
         }

         let linkedAccount = AccountHelper.getAccountWithPath(row[6], context: context)

         let account = try? AccountHelper.createAndGetAccount(parent: parent,
         name: name,
         type: TypeEnum(rawValue: accountType)!,
         currency: curency,
         impoted: true,
         context: context)
         account?.linkedAccount = linkedAccount
         account?.subType = SubTypeEnum(rawValue: accountSubType) ?? .none
         account?.active = active

         // CHECKING
         if let account = account {
         accountToBeAdded.append(account)
         var accountTypes = ""
         switch account.type {
         case TypeEnum.assets:
         accountTypes = "Assets"
         case TypeEnum.liabilities:
         accountTypes = "Liabilities"
         default:
         accountTypes = "Out of enumeration"
         }

         var accountSubTypes = ""
         switch account.subType {
         case SubTypeEnum.none:
         accountSubTypes = ""
         case SubTypeEnum.cash:
         accountSubTypes = "Cash"
         case SubTypeEnum.debitCard:
         accountSubTypes = "DebitCard"
         case SubTypeEnum.creditCard:
         accountSubTypes = "CreditCard"
         default:
         accountSubTypes = "Out of enumeration"
         }
         var export = ""
         export +=  "\(account.parent != nil ? account.parent!.path: "" ),"
         export +=  "\(account.name),"
         export +=  "\(account.active),"
         export +=  "\(accountTypes),"
         export +=  "\(account.currency?.code ?? "MULTICURRENCY"),"
         export +=  "\(accountSubTypes),"
         export +=  "\(account.linkedAccount != nil ? account.linkedAccount!.path: "" )\n"
         //            print(export)
         } else {
         print("There is no account")
         }
         }
         */
    }
}
