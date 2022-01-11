//
//  BankAccountManager.swift
//  Accountant
//
//  Created by Roman Topchii on 24.12.2021.
//

import Foundation
import CoreData

class BankAccountManager {
    
    static func isFreeId(_ id: String?, context: NSManagedObjectContext) -> Bool {
        let bankAccountFetchRequest : NSFetchRequest<BankAccount> = NSFetchRequest<BankAccount>(entityName: BankAccount.entity().name!)
        bankAccountFetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        bankAccountFetchRequest.predicate = NSPredicate(format: "id = %@", id as! CVarArg)
        
        if let ba = try? context.fetch(bankAccountFetchRequest) as! [BankAccount], ba.isEmpty {
            return true
        }
        else {
            return false
        }
    }
    
    static func createAndGetBankAccount(userBankProfile: UserBankProfile,iban: String?, strBin: String?, bin: Int16?, id: String?, lastTransactionDate:Date, context: NSManagedObjectContext) throws -> BankAccount {
        
        guard isFreeId(id, context: context) else {throw BankAccountError.alreadyExist(name: strBin)}
        
        let bankAccount = BankAccount(context: context)
        bankAccount.iban = iban
        bankAccount.strBin = strBin
        bankAccount.bin = bin ?? 0
        bankAccount.id = id
        bankAccount.locked = false //semophore  true = do not load statement data
        
        bankAccount.userBankProfile = userBankProfile
        
        let calendar = Calendar.current
        bankAccount.lastLoadDate = calendar.date(byAdding: .second, value: -60, to: Date())!

        bankAccount.lastTransactionDate = calendar.date(byAdding: .day, value: -90, to: Date())!  //Date()  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        return bankAccount
    }
    
    static func createBankAccount(userBankProfile: UserBankProfile,iban: String?, strBin: String?, bin: Int16?, id: String?, lastTransactionDate:Date, context: NSManagedObjectContext){
        try? createAndGetBankAccount(userBankProfile: userBankProfile, iban: iban, strBin: strBin, bin: bin, id: id, lastTransactionDate: lastTransactionDate, context: context)
    }
    
    static func getBankAccountList(context: NSManagedObjectContext) -> [BankAccount] {
        let bankAccountFetchRequest : NSFetchRequest<BankAccount> = NSFetchRequest<BankAccount>(entityName: BankAccount.entity().name!)
        bankAccountFetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        do {
            return try context.fetch(bankAccountFetchRequest) as! [BankAccount]
        }
        catch {
            return []
        }
    }
    
    static func getBankAccounyWithId(_ id: String, context: NSManagedObjectContext) -> BankAccount? {
        let bankAccountFetchRequest : NSFetchRequest<BankAccount> = NSFetchRequest<BankAccount>(entityName: BankAccount.entity().name!)
        bankAccountFetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        bankAccountFetchRequest.predicate = NSPredicate(format: "id = %@", id as! CVarArg)
        do {
            return (try context.fetch(bankAccountFetchRequest) as? [BankAccount])?.last
        }
        catch {
            return nil
        }
    }
    
    static func createAndGetMBBankAccount(_ mbba: MBAccountInfo, userBankProfile: UserBankProfile, context: NSManagedObjectContext) throws -> BankAccount {
        let bankAccount = try createAndGetBankAccount(userBankProfile: userBankProfile, iban: mbba.iban, strBin: mbba.maskedPan.first, bin: nil, id: mbba.id, lastTransactionDate: Calendar.current.date(byAdding: .day, value: -30, to: Date())!, context: context)
        return bankAccount
    }
    
    static func createMBBankAccount(_ mbba: MBAccountInfo, userBankProfile: UserBankProfile, context: NSManagedObjectContext) {
        createBankAccount(userBankProfile: userBankProfile, iban: mbba.iban, strBin: mbba.maskedPan.first, bin: nil, id: mbba.id, lastTransactionDate: Calendar.current.date(byAdding: .day, value: -30, to: Date())!, context: context)
    }
    
    //USE ONLY TO CLEAR DATA IN TEST ENVIRONMENT
    static func deleteAllBankAccounts(context: NSManagedObjectContext, env: Environment?) throws {
        guard env == .test else {return}
        let fetchRequest : NSFetchRequest<BankAccount> = NSFetchRequest<BankAccount>(entityName: BankAccount.entity().name!)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        
        let ba = try context.fetch(fetchRequest)
        ba.forEach({
            context.delete($0)
        })
    }
}
