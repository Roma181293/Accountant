//
//  DataForPieChart.swift
//  Accounting
//
//  Created by Roman Topchii on 26.11.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import Foundation
import Charts

struct DataForPieCharts {
    var pieChartDataEntries: [PieChartDataEntry] = []
    var centerText = NSMutableAttributedString(string:"")
    var pieChartColorSet : [NSUIColor] = []
    
    init(accountsData: [AccountData], dateInterval: DateInterval, presentingCurrency: Currency, distributionType: DistributionType, showDate: Bool) {
        var sum : Double = 0
        
        switch distributionType {
        case .amount:
            accountsData.forEach({ item in
                if item.amountInAccountingCurrency >= 0 {
                    sum += item.amountInAccountingCurrency
                    let dataEntry = PieChartDataEntry(value: item.amountInAccountingCurrency)
//                    dataEntry.label = item.title
                    pieChartColorSet.append(item.color)
                    self.pieChartDataEntries.append(dataEntry)
                }
            })
        case .currecy:
            var tmpResults : [Currency:Double] = [:]
            accountsData.forEach({ item in
                if item.amountInAccountingCurrency >= 0 {
                    sum += item.amountInAccountingCurrency
                    if let accountCurrency = item.account.currency {
                        if tmpResults[accountCurrency] != nil {
                            tmpResults[accountCurrency] = tmpResults[accountCurrency]! + item.amountInAccountingCurrency
                        }
                        else {
                            tmpResults[accountCurrency] = item.amountInAccountingCurrency
                        }
                    }
                }
            })
            for key in tmpResults.keys {
                let dataEntry = PieChartDataEntry(value: tmpResults[key]!)
                dataEntry.label = key.code!
                self.pieChartDataEntries.append(dataEntry)
            }
        }
        sum = round(sum*100)/100
        self.pieChartDataEntries = self.pieChartDataEntries.sorted(by: {$0.value > $1.value})
        
        // center text
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.alignment = .center
        
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = .short
        dateformatter.timeStyle = .none
        dateformatter.locale = Locale(identifier: "\(Bundle.main.localizations.first ?? "en")_\(Locale.current.regionCode ?? "US")")
        
        let calendar = Calendar.current
        if showDate, let dateToShow = calendar.date(byAdding: .day, value: -1, to: dateInterval.end) {
            let dateIntervalString = String("\(dateformatter.string(from: dateInterval.start))-\(dateformatter.string(from: dateToShow))")
            self.centerText = NSMutableAttributedString(string: "\(dateIntervalString)\n\(sum.formattedWithSeparator)\n\(presentingCurrency.code!)")
            self.centerText.setAttributes([.font : UIFont(name: "HelveticaNeue-Medium", size: 11)!,
                                      .paragraphStyle : paragraphStyle, .foregroundColor: UIColor.label], range: NSRange(location: 0, length: dateIntervalString.count))
            self.centerText.addAttributes([.font : UIFont(name: "HelveticaNeue-Medium", size: 18)!,
                                      .paragraphStyle : paragraphStyle, .foregroundColor: UIColor.label], range: NSRange(location: dateIntervalString.count+1, length: centerText.length-dateIntervalString.count-3))
            self.centerText.addAttributes([.font : UIFont(name: "HelveticaNeue-Medium", size: 14)!,
                                      .paragraphStyle : paragraphStyle, .foregroundColor: UIColor.label], range: NSRange(location: centerText.length-3, length: 3))
        }
        else {
            self.centerText = NSMutableAttributedString(string: "\(sum.formattedWithSeparator)\n\(presentingCurrency.code!)")
            self.centerText.setAttributes([.font : UIFont(name: "HelveticaNeue-Medium", size: 18)!,
                                           .paragraphStyle : paragraphStyle, .foregroundColor: UIColor.label], range: NSRange(location: 0, length: centerText.length))
        }
    }
    
    
    init(dataToPresent: [(account: Account, title: String, amountInAccountCurrency: Double, amountInAccountingCurrency: Double)], dateInterval: DateInterval, presentingCurrency: Currency, distributionType: DistributionType, showDate: Bool) {
        var sum : Double = 0
        
        switch distributionType {
        case .amount:
            dataToPresent.forEach({ item in
                sum += item.amountInAccountingCurrency
                let dataEntry = PieChartDataEntry(value: item.amountInAccountingCurrency)
//                dataEntry.label = item.title
                self.pieChartDataEntries.append(dataEntry)
            })
        case .currecy:
            var tmpResults : [Currency:Double] = [:]
            dataToPresent.forEach({ item in
                sum += item.amountInAccountingCurrency
                if let accountCurrency = item.account.currency {
                    if tmpResults[accountCurrency] != nil {
                        tmpResults[accountCurrency] = tmpResults[accountCurrency]! + item.amountInAccountingCurrency
                    }
                    else {
                        tmpResults[accountCurrency] = item.amountInAccountingCurrency
                    }
                }
            })
            for key in tmpResults.keys {
                let dataEntry = PieChartDataEntry(value: tmpResults[key]!)
                dataEntry.label = key.code!
                self.pieChartDataEntries.append(dataEntry)
            }
        }
        sum = round(sum*100)/100
        self.pieChartDataEntries = self.pieChartDataEntries.sorted(by: {$0.value > $1.value})
        
        // center text
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.alignment = .center
        
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = .short
        dateformatter.timeStyle = .none
        dateformatter.locale = Locale(identifier: "\(Bundle.main.localizations.first ?? "en")_\(Locale.current.regionCode ?? "US")")
        
        let calendar = Calendar.current
        if showDate, let dateToShow = calendar.date(byAdding: .day, value: -1, to: dateInterval.end) {
            let dateIntervalString = String("\(dateformatter.string(from: dateInterval.start))-\(dateformatter.string(from: dateToShow))")
            self.centerText = NSMutableAttributedString(string: "\(dateIntervalString)\n\(sum.formattedWithSeparator)\n\(presentingCurrency.code!)")
            self.centerText.setAttributes([.font : UIFont(name: "HelveticaNeue-Medium", size: 11)!,
                                      .paragraphStyle : paragraphStyle, .foregroundColor: UIColor.label], range: NSRange(location: 0, length: dateIntervalString.count))
            self.centerText.addAttributes([.font : UIFont(name: "HelveticaNeue-Medium", size: 18)!,
                                      .paragraphStyle : paragraphStyle, .foregroundColor: UIColor.label], range: NSRange(location: dateIntervalString.count+1, length: centerText.length-dateIntervalString.count-3))
            self.centerText.addAttributes([.font : UIFont(name: "HelveticaNeue-Medium", size: 14)!,
                                      .paragraphStyle : paragraphStyle, .foregroundColor: UIColor.label], range: NSRange(location: centerText.length-3, length: 3))
        }
        else {
            self.centerText = NSMutableAttributedString(string: "\(sum.formattedWithSeparator)\n\(presentingCurrency.code!)")
            self.centerText.setAttributes([.font : UIFont(name: "HelveticaNeue-Medium", size: 18)!,
                                      .paragraphStyle : paragraphStyle, .foregroundColor: UIColor.label], range: NSRange(location: 0, length: centerText.length))
        }
    }
}
