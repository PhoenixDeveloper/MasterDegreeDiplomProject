//
//  Persistence.swift
//  SmartHouseBalance
//
//  Created by Михаил Беленко on 10.05.2020.
//  Copyright © 2020 Михаил Беленко. All rights reserved.
//

import RealmSwift

class Persistence {

    static var storage = Persistence()

    private lazy var services: [ServiceModel] = Array(self.realm.objects(ServiceModel.self))

    private let realm = try! Realm()

    private init() {}

    func addService(service: ServiceModel) {
        try! realm.write {
            realm.add(service)
            services.append(service)
        }
    }

    func getServices() -> [ServiceModel] {
        return services.sorted()
    }

    func getServicesFromPeriod(date: Date) -> [ServiceModel] {
        return services.filter({ $0.datePayment > date }).sorted()
    }

    func getExpensesTotal() -> Float {
        return services.reduce(0, { $0 + $1.price })
    }
}
