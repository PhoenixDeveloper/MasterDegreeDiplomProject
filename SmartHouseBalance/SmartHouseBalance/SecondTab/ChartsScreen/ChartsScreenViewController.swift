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

        yearsSegmentedControl.removeAllSegments()

        for (index, year) in Persistence.storage.getYears().enumerated() {
            yearsSegmentedControl.insertSegment(withTitle: year, at: index, animated: false)
        }

        yearsSegmentedControl.selectedSegmentIndex = yearsSegmentedControl.numberOfSegments - 1;
        changeTitleLabel()
        changeData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        changeData()
    }

    private func setChart(_ dataPoints: [String], values: [Float]) {
        pieChartView.noDataText = "You need to provide data for the chart."

        var dataEntries: [PieChartDataEntry] = []

        for i in 0..<dataPoints.count {
            let dataEntry = PieChartDataEntry(value: Double(values[i]), label: dataPoints[i])
            dataEntries.append(dataEntry)
        }

        let chartDataSet = PieChartDataSet(entries: dataEntries, label: "")
        chartDataSet.colors = ChartColorTemplates.colorful()
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

    private func getMonthFromServices(services: [ServiceModel]) -> Dictionary<String, Float> {
        var dictionary = Dictionary<String, Float>()
        let calendar = Calendar.current

        for service in services {
            if (dictionary.keys.contains(monthNames[calendar.component(.month, from: service.datePayment) - 1])) {
                dictionary[monthNames[calendar.component(.month, from: service.datePayment) - 1]]! += service.price
            } else {
                dictionary.updateValue(service.price, forKey: monthNames[calendar.component(.month, from: service.datePayment) - 1])
            }
        }
        return dictionary
    }

    private func getNameOrganizationFromServices(services: [ServiceModel]) -> Dictionary<String, Float> {
        var dictionary = Dictionary<String, Float>()

        for service in services {
            let title = "\(service.nameOrganization)\n(\(service.typeService))"
            if (dictionary.keys.contains(title)) {
                dictionary[title]! += service.price
            } else {
                dictionary.updateValue(service.price, forKey: title)
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
