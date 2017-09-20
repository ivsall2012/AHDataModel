//
//  UserModel.swift
//  AHSQLite
//
//  Created by Andy Tong on 9/19/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import AHDataModel


struct UserModel: Equatable {
    var id: Int
    var name: String?
    var age: Int?
    var address: String?
    var phone: String?
    var score: Double?
    var isVIP: Bool?
    var balance: Double?
    var position: String?
    
    public static func ==(lhs: UserModel, rhs: UserModel) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.age == rhs.age && lhs.address == rhs.address && lhs.phone == rhs.phone && lhs.score == rhs.score && lhs.isVIP == rhs.isVIP && lhs.balance == rhs.balance && lhs.position == rhs.position
    }
}

extension UserModel: AHDataModel {
    init(id: Int) {
        self.id = id
    }
    init(id: Int, name: String, age: Int, address: String, phone: String) {
        self.id = id
        self.name = name
        self.age = age
        self.address = address
        self.phone = phone
    }
    
    init(id: Int, score: Double, isVIP: Bool, balance: Double, position: String) {
        self.id = id
        self.score = score
        self.isVIP = isVIP
        self.balance = balance
        self.position = position
    }
    
    init(with dict: [String : Any]) {
        self.id = dict["id"] as! Int
        self.name = dict["name"] as? String
        self.age = dict["age"] as? Int
        self.address = dict["address"] as? String
        self.phone = dict["phone"] as? String
        self.score = dict["score"] as? Double
        self.isVIP = Bool(dict["isVIP"])
        self.balance = dict["balance"] as? Double
        self.position = dict["position"] as? String
    }
    
    
    static func databaseFilePath() -> String {
        return "/Users/Hurricane/Go/Swift/AHFM/AHSQLite/db.sqlite"
    }
    static func columnInfo() -> [AHDBColumnInfo] {
        let id = AHDBColumnInfo(name: "id", type: .integer, constraints: "not null", "primary key")
        let name = AHDBColumnInfo(name: "name", type: .text)
        let age = AHDBColumnInfo(name: "age", type: .integer)
        let address = AHDBColumnInfo(name: "address", type: .text)
        let phone = AHDBColumnInfo(name: "phone", type: .text)
        let score = AHDBColumnInfo(name: "score", type: .real)
        let isVIP = AHDBColumnInfo(name: "isVIP", type: .integer)
        let balance = AHDBColumnInfo(name: "balance", type: .real)
        let position = AHDBColumnInfo(name: "position", type: .text)
        return [id,name,age,address,phone,score,isVIP,balance,position]
    }
    static func tableName() -> String {
        return "\(self)"
    }
    func toDict() -> [String : Any] {
        var dict = [String: Any]()
        dict["id"] = self.id
        dict["name"] = self.name
        dict["age"] = self.age
        dict["address"] = self.address
        dict["phone"] = self.phone
        dict["score"] = self.score
        dict["isVIP"] = self.isVIP
        dict["balance"] = self.balance
        dict["position"] = self.position
        return dict
    }
}
