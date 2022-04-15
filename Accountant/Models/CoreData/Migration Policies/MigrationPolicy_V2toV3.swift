//
//  AccountantMigrationPolicy_V2toV3.swift
//  Accountant
//
//  Created by Roman Topchii on 12.04.2022.
//

import Foundation
import CoreData

class MigrationPolicy_V2toV3: NSEntityMigrationPolicy { // swiftlint:disable:this type_name
    @objc func activeFor(isHidden: NSNumber) -> NSNumber {
         if isHidden.boolValue {
             return NSNumber(integerLiteral: 0) // swiftlint:disable:this compiler_protocol_init
         } else {
             return NSNumber(integerLiteral: 1) // swiftlint:disable:this compiler_protocol_init
         }
     }
}
