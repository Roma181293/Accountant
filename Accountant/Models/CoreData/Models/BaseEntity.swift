//
//  BaseEntity.swift
//  Accountant
//
//  Created by Roman Topchii on 11.04.2022.
//

import Foundation
import CoreData

class BaseEntity: NSManagedObject {
    
    @NSManaged public var id: UUID
    @NSManaged public var createDate: Date?
    @NSManaged public var createdByUser: Bool
    @NSManaged public var modifyDate: Date?
    @NSManaged public var modifiedByUser: Bool
    
    convenience init(id: UUID, createdByUser: Bool = false, createDate: Date = Date(), context: NSManagedObjectContext) {
        self.init(context: context)
        self.id = id
        self.createDate = createDate
        self.modifyDate = createDate
        self.modifiedByUser = createdByUser
        self.createdByUser = createdByUser
    }
}
