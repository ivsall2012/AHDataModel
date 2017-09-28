//
//  ChatModel.swift
//  AHDataModel
//
//  Created by Andy Tong on 9/22/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import AHDataModel

struct ChatModel: Equatable {
    var id: Int?
    var text: String
    var userId: Int
    public static func ==(lhs: ChatModel, rhs: ChatModel) -> Bool {
        return lhs.id == rhs.id && lhs.text == rhs.text && lhs.userId == rhs.userId
    }
}

extension ChatModel: AHDataModel {
    init(text: String, userId: Int) {
        self.text = text
        self.userId = userId
    }
    
    init(with dict: [String : Any?]) {
        self.id = dict["id"] as? Int
        self.text = dict["text"] as! String
        self.userId = dict["userId"] as! Int
    }
    
    
    static func databaseFilePath() -> String {
        return (NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first! as NSString).appendingPathComponent("db.sqlte")
    }
    
    static func columnInfo() -> [AHDBColumnInfo] {
        let id = AHDBColumnInfo(name: "id", type: .integer, constraints: "primary key")
        let text = AHDBColumnInfo(name: "text", type: .text)
        let userId = AHDBColumnInfo(foreginKey: "userId", type: .integer, referenceKey: "id", referenceTable: "\(UserModel.tableName())")
        return [id,text,userId]
    }
    static func tableName() -> String {
        return "\(self)"
    }
    func toDict() -> [String : Any] {
        var dict = [String: Any]()
        dict["id"] = self.id
        dict["text"] = self.text
        dict["userId"] = self.userId
        return dict
    }
}
