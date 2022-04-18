//
//  DataForPresenting.swift
//  Accounting
//
//  Created by Roman Topchii on 09.12.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import Foundation

class PresentingData {
    private var dateInterval: DateInterval!
    private var presentingCurrency: Currency!
    var lineChartData: ChartData!
    var tableData: [AccountData] = []

    init(dateInterval: DateInterval, presentingCurrency: Currency, lineChartData: ChartData, tableData: [AccountData],
         sortTableDataBy: SortCategoryType) {
        self.dateInterval = dateInterval
        self.presentingCurrency = presentingCurrency
        self.lineChartData = lineChartData
        self.tableData = tableData
        self.sortTableDataBy(sortTableDataBy)
    }

    func sortTableDataBy(_ sortCategoryType: SortCategoryType) {
        var nonNegativeValues  = tableData.filter({ $0.amountInSelectedCurrency >= 0 })

        switch sortCategoryType {
        case .aToz:
            nonNegativeValues = nonNegativeValues.sorted(by: {$0.title < $1.title})
        case .zToa:
            nonNegativeValues = nonNegativeValues.sorted(by: {$0.title > $1.title})
        case .zeroToNine:
            nonNegativeValues = nonNegativeValues.sorted(by: {$0.amountInSelectedCurrency<$1.amountInSelectedCurrency})
        case .nineToZero:
            nonNegativeValues = nonNegativeValues.sorted(by: {$0.amountInSelectedCurrency>$1.amountInSelectedCurrency})
        }

        let negativeValues  = tableData.filter({ $0.amountInSelectedCurrency < 0 })
        tableData = negativeValues + nonNegativeValues
    }

    func getDataForPieChart(distributionType: DistributionType, showDate: Bool) -> DataForPieCharts {
        return DataForPieCharts(accountsData: tableData, dateInterval: dateInterval, presentingCurrency:
                                    presentingCurrency, distributionType: distributionType, showDate: showDate)
    }
}
