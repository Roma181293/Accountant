//
//  MBStatement.swift
//  Accountant
//
//  Created by Roman Topchii on 24.12.2021.
//

import Foundation

struct MBStatement: Codable, StatementProtocol {
    let id : String
    let time : Int64
    let description : String
    let mcc: Int
    let originalMcc: Int
    let amount: Int64
    let operationAmount: Int
    let currencyCode: Int64
    let commissionRate: Int
    let cashbackAmount: Int
    let balance: Int
    let hold: Bool
    let comment: String?
    let receiptId: String?
    let counterEdrpou: String?
    let counterIban: String?
    
    func getAmount() -> Double {
        return abs(Double(amount)/100.0)
    }
    
    func getType() -> StatmentType {
        if amount > 0 {
            return .to
        }
        else {
            return .from
        }
    }
    
    func getDate() -> Date {
        return Date.init(timeIntervalSince1970: TimeInterval(time))
    }
    
    func getComment() -> String {
        return (description + ";" + (comment ?? "")).replacingOccurrences(of: "\n", with: " ") // + ";" + (receiptId ?? "")
    }
}
