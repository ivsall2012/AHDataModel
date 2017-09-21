//
//  DogModel.swift
//  AHDB2
//
//  Created by Andy Tong on 7/10/17.
//  Copyright © 2017 Andy Tong. All rights reserved.
//

import Foundation
import AHDataModel
struct Dog: Equatable{
    var masterId: Int?
    var name: String
    var age: Int
    
    public static func ==(lhs: Dog, rhs: Dog) -> Bool {
        return lhs.name == rhs.name && lhs.age == rhs.age && lhs.masterId == rhs.masterId
    }
    
}

extension Dog: AHDataModel {
    init(with dict: [String : Any?]) {
        self.age = dict["age"] as! Int
        self.name = dict["name"] as! String
        self.masterId = dict["masterId"] as? Int
    }


    static func databaseFilePath() -> String {
        return "/Users/Hurricane/Go/Swift/AHFM/AHSQLite/db.sqlite"
    }
    static func columnInfo() -> [AHDBColumnInfo] {
        let age = AHDBColumnInfo(name: "age", type: .integer, constraints: "not null")
        let name = AHDBColumnInfo(name: "name", type: .text, constraints: "not null", "primary key")
        let foreginKey = AHDBColumnInfo(foreginKey: "masterId", type: .integer, referenceKey: "id", referenceTable: "Master")
        return [age,name,foreginKey]
    }
    static func tableName() -> String {
        return "DogModel"
    }
    func toDict() -> [String : Any] {
        var dict = [String: Any]()
        dict["age"] = self.age
        dict["name"] = self.name
        dict["masterId"] = self.masterId
        return dict
    }
}
