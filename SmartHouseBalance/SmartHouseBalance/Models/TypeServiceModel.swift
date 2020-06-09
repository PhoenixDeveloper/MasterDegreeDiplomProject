//
//  TypeServiceModel.swift
//  SmartHouseBalance
//
//  Created by Михаил Беленко on 09.06.2020.
//  Copyright © 2020 Михаил Беленко. All rights reserved.
//

import RealmSwift

class TypeServiceModel: Object, Comparable {
    /// Наименование типа
    @objc dynamic var nameType: String = ""
    
    override static func primaryKey() -> String? {
        return "nameType"
    }

    static func < (lhs: TypeServiceModel, rhs: TypeServiceModel) -> Bool {
        return lhs.nameType < rhs.nameType
    }
}
