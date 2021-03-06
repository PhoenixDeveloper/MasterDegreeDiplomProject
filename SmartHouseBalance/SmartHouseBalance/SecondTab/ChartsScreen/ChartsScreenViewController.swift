//
//  ChartsScreenViewController.swift
//  SmartHouseBalance
//
//  Created by Михаил Беленко on 15.05.2020.
//  Copyright © 2020 Михаил Беленко. All rights reserved.
//

import UIKit
import Charts

class ChartsScreenViewController: UIViewController {
    @IBOutlet weak var yearsSegmentedControl: UISegmentedControl!
    @IBOutlet weak var monthSegmentedControl: UISegmentedControl!
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var backMonth: UIButton!
    @IBOutlet weak var nextMouth: UIButton!
    @IBOutlet weak var monthContainer: UIStackView!
    @IBOutlet weak var currentTitleLabel: UILabel!

    private var posibleValuesMonth: [Int] = []
    private var currentPage: Int = 0 {
        didSet {
            currentMonth = posibleValuesMonth[currentPage]
            backMonth.isHidden = currentPage == 0
            nextMouth.isHidden = currentPage == posibleValuesMonth.count - 1
        }
    }
    private var currentMonth: Int = 0 {
        didSet {
            changeTitleLabel()
        }
    }
    private var monthNames = ["январь", "февраль", "март", "апрель", "май", "июнь", "июль", "август", "сентябрь", "октябрь", "ноябрь", "декабрь"]
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if checkDataAvailable()
        {
            yearsSegmentedControl.removeAllSegments()

            for (index, year) in Persistence.storage.getYears().enumerated() {
                yearsSegmentedControl.insertSegment(withTitle: year, at: index, animated: false)
            }

            yearsSegmentedControl.selectedSegmentIndex = yearsSegmentedControl.numberOfSegments - 1;
            changeTitleLabel()
            changeData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pieChartView.noDataText = "Нет данных по расходам."
        
        if checkDataAvailable()
        {
            changeData()
        }
    }
    
    private func checkDataAvailable() -> Bool {
        if Persistence.storage.getServices().isEmpty
        {
            monthSegmentedControl.isHidden = true
            yearsSegmentedControl.isHidden = true
            currentTitleLabel.text = "Нет данных"
            return false
        } else {
            monthSegmentedControl.isHidden = false
            yearsSegmentedControl.isHidden = false
            return true
        }
        
    }

    private func setChart(_ dataPoints: [String], values: [Float]) {
        var dataEntries: [PieChartDataEntry] = []

        for i in 0..<dataPoints.count {
            let dataEntry = PieChartDataEntry(value: roundVal(Double(values[i]), toNearest: 0.01), label: dataPoints[i])
            dataEntries.append(dataEntry)
        }

        let chartDataSet = PieChartDataSet(entries: dataEntries, label: "")
        chartDataSet.colors = ChartColorTemplates.pastel()
        let chartData = PieChartData(dataSet: chartDataSet)
        pieChartView.data = chartData
    }

    private func changeTitleLabel() {
        if (monthSegmentedControl.selectedSegmentIndex == 1) {
            currentTitleLabel.text = "Данные за \(monthNames[currentMonth]) \(Persistence.storage.getYears()[yearsSegmentedControl.selectedSegmentIndex]) года";
        } else {
            currentTitleLabel.text = "Данные за \(Persistence.storage.getYears()[yearsSegmentedControl.selectedSegmentIndex]) год";
        }
        changeData()
    }

    private func changeData() {
        if (monthSegmentedControl.selectedSegmentIndex == 1) {
            let services = Persistence.storage.getServicesFromPeriod(year: Int(yearsSegmentedControl.titleForSegment(at: yearsSegmentedControl.selectedSegmentIndex)!)!, month: currentMonth + 1)
            let data = getNameOrganizationFromServices(services: services)

            let namesOrganizations = data.keys.map({ $0 })
            let expenses = data.values.map({ $0 })

            setChart(namesOrganizations, values: expenses)
        } else {
            let services = Persistence.storage.getServicesFromPeriod(year: Int(yearsSegmentedControl.titleForSegment(at: yearsSegmentedControl.selectedSegmentIndex)!)!)
            let data = getMonthFromServices(services: services)

            let months = data.keys.map({ $0 })
            posibleValuesMonth = data.keys.map({ monthNames.firstIndex(of: $0)! }).sorted()
            let expenses = data.values.map({ $0 })

            setChart(months, values: expenses)
        }
    }
    
    private func roundVal(_ value: Double, toNearest: Double) -> Double {
        return round(value / toNearest) * toNearest
    }

    private func getMonthFromServices(services: [ServiceModel]) -> Dictionary<String, Float> {
        var dictionary = Dictionary<String, Float>()
        let calendar = Calendar.current

        for service in services {
            if !(dictionary.keys.contains(monthNames[calendar.component(.month, from: service.datePayment) - 1])) {
                dictionary.updateValue(Persistence.storage.getExpensesTotalForMonth(month: calendar.component(.month, from: service.datePayment)), forKey: monthNames[calendar.component(.month, from: service.datePayment) - 1])
            }
        }
        return dictionary
    }

    private func getNameOrganizationFromServices(services: [ServiceModel]) -> Dictionary<String, Float> {
        var dictionary = Dictionary<String, Float>()
        let calendar = Calendar.current

        for service in services {
            let title = "\(service.nameOrganization)\n(\(service.typeService?.nameType ?? ""))"
            if !(dictionary.keys.contains(title)) {
                dictionary.updateValue(Persistence.storage.getExpensesTotalForOrganization(nameOrganization: service.nameOrganization, date: (calendar.component(.month, from: service.datePayment), (calendar.component(.year, from: service.datePayment)))), forKey: title)
            }
        }
        return dictionary
    }

    @IBAction func changeMonthSegment(_ sender: Any) {
        if (monthSegmentedControl.selectedSegmentIndex == 0) {
            monthContainer.isHidden = true
            yearsSegmentedControl.isHidden = false
            changeTitleLabel()
        } else {
            monthContainer.isHidden = false
            yearsSegmentedControl.isHidden = true
            currentPage = 0
        }
    }

    @IBAction func changeYearSegment(_ sender: Any) {
        changeTitleLabel()
    }

    @IBAction func backMonthButtonClick(_ sender: Any) {
        currentPage -= 1
    }

    @IBAction func nextMonthButtonClick(_ sender: Any) {
        currentPage += 1
    }
}
