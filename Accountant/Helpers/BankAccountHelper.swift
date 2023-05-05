//
//  BankAccountHelper.swift
//  Accountant
//
//  Created by Roman Topchii on 18.06.2022.
//

import Foundation
import CoreData

class BankAccountHelper {
    static func isFreeExternalId(_ externalId: String, context: NSManagedObjectContext) -> Bool {
        let fetchRequest = BankAccount.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.BankAccount.id.rawValue, ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "\(Schema.BankAccount.externalId.rawValue) = %@", externalId)
        if let bankAccount = try? context.fetch(fetchRequest), bankAccount.isEmpty {
            return true
        } else {
            return false
        }
    }

    class func createAndGet(userBankProfile: UserBankProfile, iban: String?, strBin: String?, bin: Int16?,
                            externalId: String?, context: NSManagedObjectContext) throws -> BankAccount {
        if let externalId = externalId {
            guard isFreeExternalId(externalId, context: context)
            else {throw BankAccount.Error.alreadyExist(name: strBin)}
        }
        return BankAccount(userBankProfile: userBankProfile, iban: iban, strBin: strBin, bin: bin,
                           externalId: externalId, context: context)
    }

    class func create(userBankProfile: UserBankProfile, iban: String?, strBin: String?, bin: Int16?,
                      externalId: String?, context: NSManagedObjectContext) throws {
        _ = try createAndGet(userBankProfile: userBankProfile, iban: iban, strBin: strBin,
                             bin: bin, externalId: externalId, context: context)
    }

    class func getBankAccountList(context: NSManagedObjectContext) -> [BankAccount] {
        let fetchRequest = BankAccount.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.BankAccount.id.rawValue, ascending: true)]
        do {
            return try context.fetch(fetchRequest)
        } catch {
            return []
        }
    }

    class func hasActiveBankAccounts(context: NSManagedObjectContext) -> Bool {
        let fetchRequest = BankAccount.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.BankAccount.id.rawValue, ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "\(Schema.BankAccount.active.rawValue) = true")
        do {
            return try !context.fetch(fetchRequest).isEmpty
        } catch {
            return false
        }
    }

    class func getBankAccountByExternalId(_ externalId: String, context: NSManagedObjectContext) -> BankAccount? {
        let fetchRequest = BankAccount.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.BankAccount.id.rawValue, ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "\(Schema.BankAccount.externalId.rawValue) = %@", externalId)
        do {
            return try context.fetch(fetchRequest).last
        } catch {
            return nil
        }
    }

    class func createAndGetMBBankAccount(_ mbba: MBAccountInfo, userBankProfile: UserBankProfile,
                                         context: NSManagedObjectContext) throws -> BankAccount {
        let bankAccount = try createAndGet(userBankProfile: userBankProfile, iban: mbba.iban,
                                           strBin: mbba.maskedPan.first, bin: nil, externalId: mbba.id,
                                           context: context)
        return bankAccount
    }

    class func createMBBankAccount(_ mbba: MBAccountInfo, userBankProfile: UserBankProfile,
                                   context: NSManagedObjectContext) throws {
        try create(userBankProfile: userBankProfile, iban: mbba.iban, strBin: mbba.maskedPan.first,
                   bin: nil, externalId: mbba.id, context: context)
    }

    class func changeLinkedAccount(to account: Account, for bankAccount: BankAccount, modifyDate: Date = Date(),
                                   modifiedByUser: Bool = true) throws {
        guard bankAccount.account == nil || account.type == bankAccount.account?.type else {throw BankAccount.Error.cantChangeLinkedAccountCozSubType}

        guard bankAccount.account == nil || account.currency == bankAccount.account?.currency
        else {throw BankAccount.Error.cantChangeLinkedAccountCozCurrency}

        bankAccount.account = account
        account.keeper = bankAccount.userBankProfile?.keeper
        account.modifyDate = modifyDate
        account.modifiedByUser = modifiedByUser
    }

    class func changeActiveStatusFor(_ bankAccount: BankAccount, context: NSManagedObjectContext) {
        if bankAccount.active {
            bankAccount.active = false
        } else {
            bankAccount.active = true
            bankAccount.userBankProfile?.active = true
        }
    }
}
