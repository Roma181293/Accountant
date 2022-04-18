//
//  MonoBankError.swift
//  Accountant
//
//  Created by Roman Topchii on 11.01.2022.
//

import Foundation

enum MonoBankError: AppError {
    case toEarlyToRetrieveTheData(date: Date)
}

extension MonoBankError: LocalizedError {
    private func formateDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .medium
        dateFormatter.locale = Locale(identifier: "\(Bundle.main.localizations.first ?? "en")_\(Locale.current.regionCode ?? "US")")
        return dateFormatter.string(from: date)
    }

    private func getMonoLink() -> String {
        return "https://api.monobank.ua/docs"
    }

    public var errorDescription: String? {
        switch self {
        case let .toEarlyToRetrieveTheData(date):
            return String(format: NSLocalizedString("Too early to retrive Monobank statements data. Please wait 1 minute to the next try. This limitation was imposed due to API policy %@ \n\nLast load %@ \nCurrent call %@", comment: ""), getMonoLink(), formateDate(date), formateDate(Date())) // swiftlint:disable:this line_length
        }
    }
}
