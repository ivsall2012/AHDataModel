//
//  MigrationModel.swift
//  AHDataModel
//
//  Created by Andy Tong on 9/22/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import AHDataModel

struct MigrationModel: Equatable {
    
    var id: Int?
    var age: Int?
    var score: Double?
    var name: String?
    
    public init(id: Int, age: Int?, score: Double?, name: String?) {
        self.id = id
        self.age = age
        self.score = score
        self.name = name
    }
    
    public init(age: Int?, score: Double?, name: String?) {
        self.age = age
        self.score = score
        self.name = name
    }
    
    public static func ==(lhs: MigrationModel, rhs: MigrationModel) -> Bool {
        return lhs.id == rhs.id && lhs.age == rhs.age && lhs.score == rhs.score && lhs.name == rhs.name
    }
    
}


extension MigrationModel: AHDataModel{
    init(with dict: [String : Any?]) {
        self.id = dict["id"] as? Int
        self.age = dict["age"] as? Int
        self.score = dict["score"] as? Double
        self.name = dict["name"] as? String
    }
    
    static func databaseFilePath() -> String {
        return "/Users/Hurricane/Go/Swift/AHFM/AHSQLite/db.sqlite"
    }
    
    static func columnInfo() -> [AHDBColumnInfo] {
        let primary = AHDBColumnInfo(name: "id", type: .integer, constraints: "primary key")
        let age = AHDBColumnInfo(name: "age", type: .integer)
        let score = AHDBColumnInfo(name: "score", type: .real)
        let name = AHDBColumnInfo(name: "name", type: .text)
        
        return [primary,age,score,name]
        
//        return [primary,age,score]
    }
    
    static func tableName() -> String {
        return "MigrationModel"
    }
    func toDict() -> [String : Any] {
        var dict = [String: Any]()
        dict["id"] = self.id
        dict["age"] = self.age
        dict["score"] = self.score
        dict["name"] = self.name
        return dict
    }
}
