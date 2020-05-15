//
//  MainScreenViewController.swift
//  SmartHouseBalance
//
//  Created by Михаил Беленко on 10.05.2020.
//  Copyright © 2020 Михаил Беленко. All rights reserved.
//

import UIKit
import DTTableViewManager

class MainScreenViewController: UIViewController, DTTableViewManageable {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalExpensesLabel: UILabel!

    private var totalExpenses: Float = 0 {
        didSet {
            totalExpensesLabel.text = "\(totalExpenses) руб."
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        registerCells()
    }

    private func registerCells() {
        manager.register(ServiceTableViewCell.self)
    }

    private func updateData() {
        totalExpenses = 0
        manager.memoryStorage.removeAllItems()

        for item in Persistence.storage.getServicesFromPeriod(date: getPeriod()) {
            manager.memoryStorage.addItem(item)
            totalExpenses += item.price
        }
    }

    private func getPeriod() -> Date {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            return Date(timeIntervalSinceNow: -2592000)
        case 1:
            return Date(timeIntervalSinceNow: -7776000)
        case 2:
            return Date(timeIntervalSinceNow: -31104000)
        case 3:
            return Date(timeIntervalSince1970: 0)
        default:
            fatalError("Unknown segment: \(segmentedControl.selectedSegmentIndex)")
        }
    }

    // Mock-данные
//    private func getMockedData() -> [ServiceModel] {
//        let item1 = ServiceModel(nameOrganization: "ОАО 'Горячая вода'",
//                                 typeService: "Водоснабжение",
//                                 price: 1250,
//                                 datePayment: Date(timeIntervalSinceNow: -100000))
//        let item2 = ServiceModel(nameOrganization: "ОАО 'Электро'",
//                                 typeService: "Энергоснабжение",
//                                 price: 1500,
//                                 datePayment: Date(timeIntervalSinceNow: -10000))
//        let item3 = ServiceModel(nameOrganization: "ОАО 'Коммуна'",
//                                 typeService: "Капитальный ремонт",
//                                 price: 750,
//                                 datePayment: Date(timeIntervalSinceNow: -10000000))
//        let item4 = ServiceModel(nameOrganization: "ОАО 'Холодная вода'",
//                                 typeService: "Водоснабжение",
//                                 price: 1750,
//                                 datePayment: Date(timeIntervalSinceNow: -100000000))
//        let item5 = ServiceModel(nameOrganization: "ОАО 'Защита'",
//                                 typeService: "Обслуживание домофона",
//                                 price: 350,
//                                 datePayment: Date(timeIntervalSinceNow: 10000))
//
//        return [item1, item2, item3, item4, item5]
//    }

    @IBAction func clickAddServiceButton(_ sender: Any) {
        performSegue(withIdentifier: "addServiceSegue", sender: self)
    }

    @IBAction func changePeriod(_ sender: Any) {
        updateData()
    }
}
