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

        // MARK: - PieChartData
        let chartData = PieChartData(dataSet: chartDataSet)
        // value formater
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .percent
        pFormatter.maximumFractionDigits = 1
        pFormatter.multiplier = 1
        pFormatter.percentSymbol = "%"
        chartData.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        chartData.setValueFont(.systemFont(ofSize: 14, weight: .light))
        chartData.setValueTextColor(.black)

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

        chartView.rotationWithTwoFingers = true // flag that indicates if rotation is done with two fingers or one.
        // when the chart is inside a scrollview,
        // you need a two-finger rotation because a one-finger rotation eats up all touch events.

        chartView.data = chartData
        return chartView
    }

    class func setLineChartView(chartData: ChartData) -> LineChartView {
        let chartView: LineChartView = LineChartView()

        let data = LineChartData(dataSets: chartData.lineChartDataSet)
        data.setValueTextColor(.label)
        data.setValueFont(.systemFont(ofSize: 9, weight: .light))

        chartView.data = data

        class DateValueFormatter: NSObject {
            var dateFormatter: DateFormatter!

            override init() {
                dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd.MM.yy"
            }

            func stringForValue(_ value: Double, axis: AxisBase?) -> String {
                return dateFormatter.string(from: Date(timeIntervalSince1970: value))
            }
        }

        let xAxis = chartView.xAxis
        xAxis.labelPosition = .topInside
        xAxis.labelFont = .systemFont(ofSize: 10, weight: .light)
        xAxis.labelTextColor = .label // UIColor(red: 255/255, green: 192/255, blue: 56/255, alpha: 1)
        xAxis.drawAxisLineEnabled = false
        xAxis.drawGridLinesEnabled = true
        xAxis.centerAxisLabelsEnabled = true
        xAxis.granularity = 3600*24*4
        xAxis.valueFormatter = IndexAxisValueFormatter()

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
        chartView.legend.form = .line
        chartView.legend.textColor = .label
        chartView.animate(xAxisDuration: 3)

        return chartView
    }
}
