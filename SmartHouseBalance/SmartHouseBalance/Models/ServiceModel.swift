//
//  ServiceModel.swift
//  SmartHouseBalance
//
//  Created by Михаил Беленко on 10.05.2020.
//  Copyright © 2020 Михаил Беленко. All rights reserved.
//

import RealmSwift

// TODO: Раскоментировать при начале работы с Realm
class ServiceModel: Object, Comparable {
    /// Наименование организации
    @objc dynamic var nameOrganization: String = ""
    /// Тип услуги
    @objc dynamic var typeService: String = ""
    /// Стоимость
    @objc dynamic var price: Float = 0
    /// Дата оплаты
    @objc dynamic var datePayment: Date = Date()

    static func < (lhs: ServiceModel, rhs: ServiceModel) -> Bool {
        return lhs.datePayment < rhs.datePayment
    }
}

// Раскомментировать при работе с Mock-данными
//struct ServiceModel: Comparable {
//
//
//    /// Наименование организации
//    var nameOrganization: String = ""
//    /// Тип услуги
//    var typeService: String = ""
//    /// Стоимость
//    var price: Float = 0
//    /// Дата оплаты
//    var datePayment: Date = Date()
//}
