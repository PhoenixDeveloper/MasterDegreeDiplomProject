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
    private lazy var serviceTypes: [TypeServiceModel] = Array(self.realm.objects(TypeServiceModel.self))

    private let realm = try! Realm()

    private init() {}

    func addService(service: ServiceModel) {
        try! realm.write {
            realm.add(service)
            services.append(service)
        }
    }
    
    func addServiceType(type: TypeServiceModel) {
        try! realm.write {
            realm.add(type)
            serviceTypes.append(type)
        }
    }

    func getServices() -> [ServiceModel] {
        return services.sorted()
    }

    func getServicesFromPeriod(date: Date) -> [ServiceModel] {
        return services.filter({ $0.datePayment > date }).sorted()
    }

    func getServicesFromPeriod(year: Int, month: Int? = nil) -> [ServiceModel] {
        let calendar = Calendar.current
        let services = self.services.filter({ calendar.component(.year, from: $0.datePayment) == year})
        return month != nil ? services.filter({ calendar.component(.month, from: $0.datePayment) == month! }) : services
    }
    
    func getServiceTypes() -> [TypeServiceModel] {
        return serviceTypes.sorted()
    }
    
    func getServiceTypesName() -> [String] {
        return serviceTypes.sorted().map({ $0.nameType })
    }
    
    func getServiceTypeByName(name: String) -> TypeServiceModel? {
        return serviceTypes.filter({ $0.nameType == name }).first
    }
    
    func getCountServiceTypes() -> Int {
        serviceTypes.count
    }
    
    func getExpensesTotalForMonth(month: Int) -> Float {
        let calendar = Calendar.current
        return calculateExpensesForServices(services: services.filter({ calendar.component(.month, from: $0.datePayment) == month }))
    }
    
    func getExpensesTotalForOrganization(nameOrganization: String, date: (month: Int, year: Int)? = nil) -> Float {
        let calendar = Calendar.current
        if (date != nil) {
            let servicesY = self.services.filter({ calendar.component(.year, from: $0.datePayment) == date!.year})
            let servicesM = servicesY.filter({ calendar.component(.month, from: $0.datePayment) == date!.month })
            return calculateExpensesForServices(services: servicesM.filter({ $0.nameOrganization == nameOrganization }))
        }
        return calculateExpensesForServices(services: services.filter({ $0.nameOrganization == nameOrganization }))
    }

    func getExpensesTotal() -> Float {
        return calculateExpensesForServices(services: services)
    }

    func getYears() -> [String] {
        var years: [String] = []
        let calendar = Calendar.current
        for service in services {
            let year = "\(calendar.component(.year, from: service.datePayment))"
            if !(years.contains(year)) {
                years.append(year)
            }
        }
        return years.sorted()
    }
    
    private func calculateExpensesForServices(services: [ServiceModel]) -> Float {
        return round(services.reduce(0, { $0 + $1.price }), toNearest: 0.01)
    }
    
    private func round(_ value: Float, toNearest: Float) -> Float {
      return roundf(value / toNearest) * toNearest
    }
}
