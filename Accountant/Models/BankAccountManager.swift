//
//  BankAccountManager.swift
//  Accountant
//
//  Created by Roman Topchii on 24.12.2021.
//

import Foundation
import CoreData

class BankAccountManager {
    
    static func isFreeExternalId(_ externalId: String?, context: NSManagedObjectContext) -> Bool {
        let bankAccountFetchRequest : NSFetchRequest<BankAccount> = NSFetchRequest<BankAccount>(entityName: BankAccount.entity().name!)
        bankAccountFetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        bankAccountFetchRequest.predicate = NSPredicate(format: "externalId = %@", externalId as! CVarArg)
        
        if let ba = try? context.fetch(bankAccountFetchRequest) as! [BankAccount], ba.isEmpty {
            return true
        }
        else {
            return false
        }
    }
    
    static func createAndGetBankAccount(userBankProfile: UserBankProfile,iban: String?, strBin: String?, bin: Int16?, externalId: String?, lastTransactionDate:Date, context: NSManagedObjectContext) throws -> BankAccount {
        
        guard isFreeExternalId(externalId, context: context) else {throw BankAccountError.alreadyExist(name: strBin)}
        
        let bankAccount = BankAccount(context: context)
        bankAccount.active = true
        bankAccount.iban = iban
        bankAccount.strBin = strBin
        bankAccount.bin = bin ?? 0
        bankAccount.externalId = externalId
        bankAccount.id = UUID()
        bankAccount.locked = false //semophore  true = do not load statement data
        
        bankAccount.userBankProfile = userBankProfile
        
        let calendar = Calendar.current
        bankAccount.lastLoadDate = calendar.date(byAdding: .second, value: -60, to: Date())!

        bankAccount.lastTransactionDate = calendar.date(byAdding: .day, value: -90, to: Date())!  //Date()  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        return bankAccount
    }
    
    static func createBankAccount(userBankProfile: UserBankProfile,iban: String?, strBin: String?, bin: Int16?, externalId: String?, lastTransactionDate:Date, context: NSManagedObjectContext){
        try? createAndGetBankAccount(userBankProfile: userBankProfile, iban: iban, strBin: strBin, bin: bin, externalId: externalId, lastTransactionDate: lastTransactionDate, context: context)
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
    
    static func getBankAccountByExternalId(_ externalId: String, context: NSManagedObjectContext) -> BankAccount? {
        let bankAccountFetchRequest : NSFetchRequest<BankAccount> = NSFetchRequest<BankAccount>(entityName: BankAccount.entity().name!)
        bankAccountFetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        bankAccountFetchRequest.predicate = NSPredicate(format: "externalId = %@", externalId as! CVarArg)
        do {
            return (try context.fetch(bankAccountFetchRequest) as? [BankAccount])?.last
        }
        catch {
            return nil
        }
    }
    
    static func createAndGetMBBankAccount(_ mbba: MBAccountInfo, userBankProfile: UserBankProfile, context: NSManagedObjectContext) throws -> BankAccount {
        let bankAccount = try createAndGetBankAccount(userBankProfile: userBankProfile, iban: mbba.iban, strBin: mbba.maskedPan.first, bin: nil, externalId: mbba.id, lastTransactionDate: Calendar.current.date(byAdding: .day, value: -30, to: Date())!, context: context)
        return bankAccount
    }
    
    static func createMBBankAccount(_ mbba: MBAccountInfo, userBankProfile: UserBankProfile, context: NSManagedObjectContext) {
        createBankAccount(userBankProfile: userBankProfile, iban: mbba.iban, strBin: mbba.maskedPan.first, bin: nil, externalId: mbba.id, lastTransactionDate: Calendar.current.date(byAdding: .day, value: -30, to: Date())!, context: context)
    }
    
    static func findNotValidAccountCandidateForLinking(for bankAccount: BankAccount) -> [Account] {
        guard let account = bankAccount.account else {return []}
        var siblings = bankAccount.account?.parent?.directChildren?.allObjects as! [Account]
        siblings = siblings.filter{
            if $0.subType != account.subType || $0.currency != account.currency || $0 == account {
                return true
            }
            return false
        }
        return siblings
    }
    
    static func changeLinkedAccount(to account: Account, for bankAccount: BankAccount) throws {
        guard account.type == bankAccount.account?.type else {return}
        guard account.subType == bankAccount.account?.subType else {throw BankAccountError.cantChangeLinkedAccountCozSubType}
        guard account.currency == bankAccount.account?.currency else {throw BankAccountError.cantChangeLinkedAccountCozCurrency}
        bankAccount.account = account
        account.keeper = bankAccount.userBankProfile?.keeper
        account.modifyDate = Date()
        account.modifiedByUser = true
    }
    
    static func changeActiveStatusFor(_ bankAccount: BankAccount, context: NSManagedObjectContext) {
        if bankAccount.active {
            bankAccount.active = false
        }
        else {
            bankAccount.active = true
            
            bankAccount.userBankProfile?.active = true
        }
    }
    
    static func deleteBankAccount(_ bankAccount: BankAccount, consentText: String, context: NSManagedObjectContext) throws {
        if consentText == "MyBudget: Finance keeper" {
            context.delete(bankAccount)
        }
        else {
            throw UserBankProfileError.invalidConsentText(consentText)
        }
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
