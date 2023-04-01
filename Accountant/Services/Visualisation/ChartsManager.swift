//
//  AnalyticsCharts.swift
//  Accounting
//
//  Created by Roman Topchii on 03.06.2020.
//  Copyright © 2020 Roman Topchii. All rights reserved.
//

import Foundation
import Charts

class ChartsManager {

    class func setPieChartView(dataForPieCharts: DataForPieCharts) -> PieChartView {

        // MARK: - PieChartDataSet
        let chartDataSet = PieChartDataSet(entries: dataForPieCharts.pieChartDataEntries, label: "")
        chartDataSet.valueLineColor = .label

        // configure colors for dataSet
        if dataForPieCharts.pieChartColorSet.isEmpty == false {
            chartDataSet.colors = dataForPieCharts.pieChartColorSet
        } else {
            chartDataSet.colors = Constants.ColorSetForCharts.set + Constants.ColorSetForCharts.set1
        }

        // MARK: - PieChartView
        let chartView: PieChartView = PieChartView()

        // avoid legend drawing
        chartView.legend.enabled = false

        // entry label styling
        chartView.entryLabelColor = .label
        chartView.entryLabelFont = .systemFont(ofSize: 12, weight: .light)

        // hole configure
        chartView.holeColor = .systemBackground
        chartView.holeRadiusPercent = 0.58
        chartView.transparentCircleRadiusPercent = 0.61
        chartView.drawHoleEnabled = true

        // configure hole content
        chartView.drawCenterTextEnabled = true
        chartView.centerAttributedText = dataForPieCharts.centerText

        chartView.drawEntryLabelsEnabled = true
        chartView.usePercentValuesEnabled = true
        chartView.isUserInteractionEnabled = false

        chartView.maxAngle = 360 // Full chart
        chartView.rotationAngle = 270 // Rotate to make the half on the upper side

        chartView.animate(xAxisDuration: 1.4)
        chartView.animate(yAxisDuration: 1.4)
        chartView.animate(xAxisDuration: 1.4, yAxisDuration: 1.4)

        chartView.rotationWithTwoFingers = true
        
        let chartData = PieChartData(dataSet: chartDataSet)
        chartView.data = chartData
        
        // value formater
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .percent
        pFormatter.maximumFractionDigits = 1
        pFormatter.multiplier = 1
//        pFormatter.percentSymbol = "%"
        chartData.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        chartData.setValueFont(.systemFont(ofSize: 14, weight: .light))
        chartData.setValueTextColor(.black)
        return chartView
    }

    class func setLineChartView(chartData: ChartData) -> LineChartView {
        let chartView: LineChartView = LineChartView()

        let data = LineChartData(dataSets: chartData.lineChartDataSet)
        data.setValueTextColor(.label)
        data.setValueFont(.systemFont(ofSize: 9, weight: .light))

        chartView.data = data

        class DateValueFormatter: AxisValueFormatter {
            var dateFormatter: DateFormatter!

            init() {
                dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                dateFormatter.timeStyle = .none
                dateFormatter.locale = Locale(identifier: "\(Bundle.main.localizations.first ?? "en")_\(Locale.current.regionCode ?? "US")") //
            }

            func stringForValue(_ value: Double, axis: AxisBase?) -> String {
                return dateFormatter.string(from: Date(timeIntervalSince1970: value))
            }
        }
        
        let xAxis = chartView.xAxis
//        xAxis.avoidFirst LastClippingEnabled = true
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 10, weight: .light)
        xAxis.labelTextColor = .label
        xAxis.drawAxisLineEnabled = false
        xAxis.drawGridLinesEnabled = true
        xAxis.centerAxisLabelsEnabled = true
        xAxis.enabled = true
        
        if let line = chartData.lineChartDataSet.first,
            let min = line.entries.map({return $0.x}).min(),
            let max = line.entries.map({return $0.x}).max(),
            min != max {
            xAxis.granularity = (max-min)/6.0
        }
        xAxis.valueFormatter = DateValueFormatter()
        
        let leftAxis = chartView.leftAxis
        leftAxis.labelPosition = .insideChart
        leftAxis.labelFont = .systemFont(ofSize: 12, weight: .light)
        leftAxis.labelTextColor = .label
        leftAxis.drawGridLinesEnabled = true
        leftAxis.granularityEnabled = true
        leftAxis.axisMinimum = chartData.minValue * 1.1
        leftAxis.axisMaximum = chartData.maxValue * 1.1
        leftAxis.yOffset = 0

        chartView.rightAxis.enabled = false
        chartView.legend.enabled = false
//        chartView.legend.textColor = .label
        chartView.animate(xAxisDuration: 3)
        chartView.isUserInteractionEnabled = false
        return chartView
    }
}
