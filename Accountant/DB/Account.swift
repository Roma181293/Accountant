//
//  Account.swift
//  Accountant
//
//  Created by Roman Topchii on 08.03.2022.
//

import Foundation
import CoreData

extension Account {
    
    convenience init(parent: Account?, name : String, type : Int16?, currency : Currency?, keeper: Keeper?, holder: Holder?, subType : Int16? = nil, createdByUser : Bool = true, createDate: Date = Date(), context: NSManagedObjectContext) {
        
        self.init(context: context)
        self.id = UUID()
        self.createDate = createDate
        self.createdByUser = createdByUser
        self.modifyDate = createDate
        self.modifiedByUser = createdByUser
        self.name = name
        
        self.currency = currency
        self.keeper = keeper
        self.holder = holder
        
        if let subType = subType {
            self.subType = subType
        }
        
        if let parent = parent {
            self.parent = parent
            self.isHidden = parent.isHidden
            self.addToAncestors(parent)
            if let parentAncestors = parent.ancestors {
                self.addToAncestors(parentAncestors)
            }
            self.level = parent.level + 1
            self.path = parent.path!+":"+name
            self.type = parent.type
        }
        else {
            self.level = 0
            self.path = name
            self.type = type!
        }
    }
    
    var rootAccount: Account {
        for item in ancestors?.allObjects as! [Account] {
            if item.level == 0 {
                return item
            }
        }
        return self
    }
    
    var directChildrenList: [Account] {
        return directChildren?.allObjects as! [Account]
    }
    
    var childrenList: [Account] {
        return children?.allObjects as! [Account]
    }
    
    var ancestorList: [Account] {
        return ancestors?.allObjects as! [Account]
    }
    
    var transactionItemsList: [TransactionItem] {
        return transactionItems?.allObjects as! [TransactionItem]
    }
    
    var isFreeFromTransactionItems: Bool {
        return transactionItemsList.isEmpty 
    }
    
    func getSubAccountWith(name: String) -> Account? {
        for child in childrenList {
            if child.name == name {
                return child
            }
        }
        return nil
    }
}
