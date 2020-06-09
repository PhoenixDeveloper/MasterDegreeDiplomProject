//
//  AddServiceScreenViewController.swift
//  SmartHouseBalance
//
//  Created by Михаил Беленко on 10.05.2020.
//  Copyright © 2020 Михаил Беленко. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class AddServiceScreenViewController: UIViewController {
    @IBOutlet weak var nameOrganizationTextField: UITextField!
    @IBOutlet weak var typeServiceTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var metersDataTextField: UITextField!
    @IBOutlet weak var datePaymentTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    var disposeBag = DisposeBag()
    
    private var datePicker: UIDatePicker?
    private var typePicker: UIPickerView?

    let dateFormatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter.dateFormat = "dd.MM.yyyy"

        errorLabel.isHidden = true
        
        typePicker = UIPickerView()
        typePicker?.delegate = self
        typePicker?.dataSource = self
        
        typeServiceTextField.inputView = typePicker

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
            service.typeService = Persistence.storage.getServiceTypeByName(name: typeServiceTextField.text!)
            service.price = Float(priceTextField.text!)!
            if let metersData = metersDataTextField.text,
                let _ = Float(metersData) {
                service.metersData.value = Float(metersDataTextField.text!)
            }
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
    
    func showAddTypeAlert() {

        let alert = UIAlertController(title: "Добавление типа расхода", message: "Введите наименование типа", preferredStyle: .alert)

        alert.addTextField()
        let textField = alert.textFields![0] // Force unwrapping because we know it exists.
        let saveAction = UIAlertAction(title: "Добавить", style: .default, handler: { (_) in
            let type = TypeServiceModel()
            type.nameType = textField.text!
            Persistence.storage.addServiceType(type: type)
        })

        let cancelAction = UIAlertAction(title: "Отмена",
            style: .default) { (action: UIAlertAction!) -> Void in
        }

        textField.rx.text.subscribe(onNext: { text in
            if let text = text, !text.isEmpty {
                saveAction.isEnabled = true
            }
            else {
                saveAction.isEnabled = false
            }
            }).disposed(by: disposeBag)

        alert.addAction(saveAction)
        alert.addAction(cancelAction)


        self.present(alert, animated: true, completion: nil)
    }
}

extension AddServiceScreenViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Persistence.storage.getCountServiceTypes() + 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return row != Persistence.storage.getCountServiceTypes() ? Persistence.storage.getServiceTypesName()[row] : "Добавить новый"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (row != Persistence.storage.getCountServiceTypes()) {
            typeServiceTextField.text = Persistence.storage.getServiceTypesName()[row]
        } else {
            showAddTypeAlert()
        }
    }
}
