//
//  MigrationModel.swift
//  AHDataModel
//
//  Created by Andy Tong on 9/22/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import AHDataModel

struct MigrationModel {
    
    var id: Int?
    var firstName: String?
    var lastName: String?
    var fullName: String?
    
    
    public init(id: Int, firstName: String?,lastName: String?) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
    }
    
}


extension MigrationModel: AHDataModel{
    init(with dict: [String : Any]) {
        self.id = dict["id"] as? Int
//        self.firstName = dict["firstName"] as? String
//        self.lastName = dict["lastName"] as? String
        
        // after migration property
        self.fullName = dict["fullName"] as? String
    }
    
    static func databaseFilePath() -> String {
        return (NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first! as NSString).appendingPathComponent("db.sqlte")
    }
    
    static func columnInfo() -> [AHDBColumnInfo] {
        let primary = AHDBColumnInfo(name: "id", type: .integer, constraints: "primary key")

//        let firstName = AHDBColumnInfo(name: "firstName", type: .text)
//        let lastName = AHDBColumnInfo(name: "lastName", type: .text)
//        return [primary,firstName,lastName]
        
        let fullName = AHDBColumnInfo(name: "fullName", type: .text)
        return [primary,fullName]
        
    }
    
    static func tableName() -> String {
        return "MigrationModel"
    }
    func toDict() -> [String : Any] {
        var dict = [String: Any]()
        dict["id"] = self.id
//        dict["firstName"] = self.firstName
//        dict["lastName"] = self.lastName
        dict["fullName"] = self.lastName
        return dict
    }
}
