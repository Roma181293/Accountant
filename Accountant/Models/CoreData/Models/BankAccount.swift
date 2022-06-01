//
//  BankAccount.swift
//  Accountant
//
//  Created by Roman Topchii on 24.12.2021.
//

import Foundation
import CoreData

final class BankAccount: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BankAccount> {
        return NSFetchRequest<BankAccount>(entityName: "BankAccount")
    }

    @NSManaged public var id: UUID
    @NSManaged public var externalId: String?
    @NSManaged public var active: Bool
    @NSManaged public var bin: Int16
    @NSManaged public var iban: String?
    @NSManaged public var lastLoadDate: Date?
    @NSManaged public var lastTransactionDate: Date?
    @NSManaged public var locked: Bool
    @NSManaged public var strBin: String?
    @NSManaged public var account: Account?
    @NSManaged public var userBankProfile: UserBankProfile?

    convenience init(userBankProfile: UserBankProfile, iban: String?, strBin: String?, bin: Int16?,
                     externalId: String?, lastTransactionDate: Date = Date(), context: NSManagedObjectContext) {
        
        self.init(context: context)
        self.active = true
        self.iban = iban
        self.strBin = strBin
        self.bin = bin ?? 0
        self.externalId = externalId
        self.id = UUID()
        self.locked = false // semophore  true = do not load statement data
        self.userBankProfile = userBankProfile
        let calendar = Calendar.current
        self.lastTransactionDate = lastTransactionDate // calendar.date(byAdding: .day, value: -90, to: Date())!
        self.lastLoadDate = calendar.date(byAdding: .second, value: -60, to: lastTransactionDate)!
    }

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

    static func createAndGet(userBankProfile: UserBankProfile, iban: String?, strBin: String?, bin: Int16?,
                             externalId: String?, context: NSManagedObjectContext) throws -> BankAccount {
        if let externalId = externalId {
            guard isFreeExternalId(externalId, context: context)
            else {throw BankAccountError.alreadyExist(name: strBin)}
        }
        return BankAccount(userBankProfile: userBankProfile, iban: iban, strBin: strBin, bin: bin,
                           externalId: externalId, context: context)
    }

    static func create(userBankProfile: UserBankProfile, iban: String?, strBin: String?, bin: Int16?,
                       externalId: String?, context: NSManagedObjectContext) throws {
        _ = try createAndGet(userBankProfile: userBankProfile, iban: iban, strBin: strBin,
                                  bin: bin, externalId: externalId, context: context)
    }

    static func getBankAccountList(context: NSManagedObjectContext) -> [BankAccount] {
        let fetchRequest = BankAccount.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.BankAccount.id.rawValue, ascending: true)]
        do {
            return try context.fetch(fetchRequest)
        } catch {
            return []
        }
    }

    static func hasActiveBankAccounts(context: NSManagedObjectContext) -> Bool {
        let fetchRequest = BankAccount.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.BankAccount.id.rawValue, ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "\(Schema.BankAccount.active.rawValue) = true")
        do {
            return try !context.fetch(fetchRequest).isEmpty
        } catch {
            return false
        }
    }

    static func getBankAccountByExternalId(_ externalId: String, context: NSManagedObjectContext) -> BankAccount? {
        let fetchRequest = BankAccount.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Schema.BankAccount.id.rawValue, ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "\(Schema.BankAccount.externalId.rawValue) = %@", externalId)
        do {
            return try context.fetch(fetchRequest).last
        } catch {
            return nil
        }
    }

    static func createAndGetMBBankAccount(_ mbba: MBAccountInfo, userBankProfile: UserBankProfile,
                                          context: NSManagedObjectContext) throws -> BankAccount {
        let bankAccount = try createAndGet(userBankProfile: userBankProfile, iban: mbba.iban,
                                        strBin: mbba.maskedPan.first, bin: nil, externalId: mbba.id, context: context)
        return bankAccount
    }

    static func createMBBankAccount(_ mbba: MBAccountInfo, userBankProfile: UserBankProfile,
                                    context: NSManagedObjectContext) throws {
        try create(userBankProfile: userBankProfile, iban: mbba.iban, strBin: mbba.maskedPan.first,
                   bin: nil, externalId: mbba.id, context: context)
    }

    func findNotValidAccountCandidateForLinking() -> [Account] {
        guard let account = self.account, let siblings = self.account?.parent?.directChildrenList else {return []}
        return siblings.filter({
            $0.type != account.type || $0.currency != account.currency || $0 == account || $0.bankAccount != nil
        })
    }

    static func changeLinkedAccount(to account: Account, for bankAccount: BankAccount, modifyDate: Date = Date(),
                                    modifiedByUser: Bool = true) throws {
        guard account.type == bankAccount.account?.type else {throw BankAccountError.cantChangeLinkedAccountCozSubType}

        guard account.currency == bankAccount.account?.currency
        else {throw BankAccountError.cantChangeLinkedAccountCozCurrency}

        bankAccount.account = account
        account.keeper = bankAccount.userBankProfile?.keeper
        account.modifyDate = modifyDate
        account.modifiedByUser = modifiedByUser
    }

    static func changeActiveStatusFor(_ bankAccount: BankAccount, context: NSManagedObjectContext) {
        if bankAccount.active {
            bankAccount.active = false
        } else {
            bankAccount.active = true
            bankAccount.userBankProfile?.active = true
        }
    }

    func delete(consentText: String) throws {
        if consentText == "MyBudget: Finance keeper" {
            managedObjectContext?.delete(self)
        } else {
            throw UserBankProfileError.invalidConsentText(consentText)
        }
    }
}
