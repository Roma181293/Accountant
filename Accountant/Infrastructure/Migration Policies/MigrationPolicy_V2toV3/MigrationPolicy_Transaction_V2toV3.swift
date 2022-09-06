//
//  MigrationPolicy_Transaction_V2toV3.swift
//  Accountant
//
//  Created by Roman Topchii on 17.07.2022.
//

import Foundation
import CoreData

class MigrationPolicy_Transaction_V2toV3: NSEntityMigrationPolicy { // swiftlint:disable:this type_name

    // FUNCTION($entityPolicy, "statusForApplied:" , $source.applied)
    @objc func statusFor(applied: NSNumber) -> NSNumber {
        if applied.boolValue {
            return NSNumber(integerLiteral: 3) // swiftlint:disable:this compiler_protocol_init
        } else {
            return NSNumber(integerLiteral: 1) // swiftlint:disable:this compiler_protocol_init
        }
    }

    override func end(_ mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        
    }

    // FUNCTION($entityPolicy, "transactionType")
    @objc func transactionType() -> NSNumber {
        return NSNumber(integerLiteral: 5)
    }
}
