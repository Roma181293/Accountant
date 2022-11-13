//
//  Statement.swift
//  Accountant
//
//  Created by Roman Topchii on 25.12.2021.
//

import Foundation

enum StatmentType {
    case from
    case to // swiftlint:disable:this identifier_name
}
protocol StatementProtocol {
    func getAmount() -> Double
    func getType() -> StatmentType
    func getDate() -> Date
    func getComment() -> String
}
