//
//  UserBankProfile.swift
//  Accountant
//
//  Created by Roman Topchii on 28.11.2021.
//

import Foundation
import CoreData


final class UserBankProfile: NSManagedObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserBankProfile> {
        return NSFetchRequest<UserBankProfile>(entityName: "UserBankProfile")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var externalId: String?
    @NSManaged public var name: String?
    @NSManaged public var active: Bool
    @NSManaged public var xToken: String?
    @NSManaged public var bankAccounts: Set<BankAccount>
    @NSManaged public var keeper: Keeper?
    
    convenience init(name: String, externalId: String?, keeper: Keeper, xToken: String, context: NSManagedObjectContext) {
        self.init(context: context)
        self.name = name
        self.active = true
        self.xToken = xToken
        self.id = UUID()
        self.externalId = externalId
        self.keeper = keeper
    }
    
    var bankAccountsList: [BankAccount] {
        return Array(bankAccounts)
    }
    
    static func isFreeExternalId(_ externalId: String, context: NSManagedObjectContext) -> Bool {
        let userBankProfileFetchRequest : NSFetchRequest<UserBankProfile> = NSFetchRequest<UserBankProfile>(entityName: UserBankProfile.entity().name!)
        userBankProfileFetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        userBankProfileFetchRequest.predicate = NSPredicate(format: "externalId = %@", externalId as! CVarArg)
        
        if let ba = try? context.fetch(userBankProfileFetchRequest), ba.isEmpty {
            return true
        }
        else {
            return false
        }
    }
    
    static func getUBP(_ externalId: String, context: NSManagedObjectContext) -> UserBankProfile? {
        let userBankProfileFetchRequest : NSFetchRequest<UserBankProfile> = NSFetchRequest<UserBankProfile>(entityName: UserBankProfile.entity().name!)
        userBankProfileFetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        userBankProfileFetchRequest.predicate = NSPredicate(format: "externalId = %@", externalId)
        
        if let ubps = try? context.fetch(userBankProfileFetchRequest), !ubps.isEmpty {
            print(#function, "ubps.count", ubps.count)
            
            let ubp = ubps.last!
            return ubp
        }
        else {
            return nil
        }
    }
    
    static func getOrCreateMonoBankUBP(_ mbui: MBUserInfo, xToken: String, context: NSManagedObjectContext) -> UserBankProfile {
        
        let userBankProfileFetchRequest : NSFetchRequest<UserBankProfile> = NSFetchRequest<UserBankProfile>(entityName: UserBankProfile.entity().name!)
        userBankProfileFetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        userBankProfileFetchRequest.predicate = NSPredicate(format: "externalId = %@", mbui.clientId)
        
        if let ubps = try? context.fetch(userBankProfileFetchRequest), ubps.isEmpty == false {
            let ubp = ubps.last!
            ubp.xToken = xToken
            return ubp
        }
        else {
            let keeper = try! Keeper.getOrCreate(name: NSLocalizedString("Monobank", comment: ""), type: .bank, createdByUser: false, context: context) //can be forced unwrapped coz this method shouldnt return error
            return UserBankProfile(name: mbui.name, externalId: mbui.clientId, keeper: keeper, xToken: xToken, context: context)
        }
    }
    
    func changeActiveStatus() {
        if self.active {
            self.active = false
            self.bankAccountsList.forEach({
                $0.active = false
            })
        }
        else {
            self.active = true
        }
    }
    
    func delete(consentText: String) throws {
        if consentText == "MyBudget: Finance keeper" {
            try bankAccountsList.forEach({
                try $0.delete(consentText: consentText)
            })
            managedObjectContext?.delete(self)
        }
        else {
            throw UserBankProfileError.invalidConsentText(consentText)
        }
    }
}
