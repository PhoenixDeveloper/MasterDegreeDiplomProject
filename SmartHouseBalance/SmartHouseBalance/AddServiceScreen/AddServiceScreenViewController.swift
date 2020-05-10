//
//  AddServiceScreenViewController.swift
//  SmartHouseBalance
//
//  Created by Михаил Беленко on 10.05.2020.
//  Copyright © 2020 Михаил Беленко. All rights reserved.
//

import UIKit

class AddServiceScreenViewController: UIViewController {
    @IBOutlet weak var nameOrganizationTextField: UITextField!
    @IBOutlet weak var typeServiceTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var datePaymentTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    private var datePicker: UIDatePicker?

    let dateFormatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter.dateFormat = "dd.MM.yyyy"

        errorLabel.isHidden = true

        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.addTarget(self, action: #selector(dateChanged(datePicker:)), for: .valueChanged)

        datePaymentTextField.inputView = datePicker
    }

    @objc func dateChanged(datePicker: UIDatePicker) {
        datePaymentTextField.text = dateFormatter.string(from: datePicker.date)
    }

    @IBAction func addServiceButtonClick(_ sender: Any) {
        if validate() {
            let service = ServiceModel()
            service.nameOrganization = nameOrganizationTextField.text!
            service.typeService = typeServiceTextField.text!
            service.price = Float(priceTextField.text!)!
            service.datePayment = dateFormatter.date(from: datePaymentTextField.text!)!
            Persistence.storage.addService(service: service)
            navigationController?.popViewController(animated: true)
        }
    }

    private func validate() -> Bool {
        if let nameOrganization = nameOrganizationTextField.text,
            let typeService = typeServiceTextField.text,
            let price = priceTextField.text,
            let _ = Float(price),
            let date = datePaymentTextField.text,
            let _ = dateFormatter.date(from: date),
            !nameOrganization.isEmpty && !typeService.isEmpty && !price.isEmpty && !date.isEmpty
        {
            errorLabel.isHidden = true
            return true
        } else {
            errorLabel.isHidden = false
            return false
        }
    }
}
