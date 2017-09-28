//
//  AHDataModel_Other_Tests.swift
//  AHDataModel
//
//  Created by Andy Tong on 9/21/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
@testable import AHDataModel


class AHDataModel_Other_Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        UserModel.shouldCheckWriteQueue = false
        try! UserModel.deleteAll()
        
        Master.shouldCheckWriteQueue = false
        try! Master.deleteAll()
        
        Dog.shouldCheckWriteQueue = false
        try! Dog.deleteAll()
        
        ChatModel.shouldCheckWriteQueue = false
        try! ChatModel.deleteAll()
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
//        try! UserModel.deleteAll()
//        try! ChatModel.deleteAll()
    }
    
    
    /// Go to UserModel and comment/uncomment corresponding codes !!!!
    func testMigration_A() {
        try! UserModel.deleteAll()
        try! ChatModel.deleteAll()
        let u1 = UserModel(id: 12, name: "user1", age: 25, address: "Las Vegas", phone: "702702702")
        let u2 = UserModel(id: 13, name: "user2", age: 26, address: "Las Vegas", phone: "702702702")
        XCTAssert(u1.save() && u2.save())
        
        
        let chat1 = ChatModel(text: "chat1", userId: 12)
        let chat2 = ChatModel(text: "chat2", userId: 12)
        let chat3 = ChatModel(text: "chat3", userId: 12)
        let chat4 = ChatModel(text: "chat4", userId: 12)
        let chat5 = ChatModel(text: "chat5", userId: 12)
        let chat6 = ChatModel(text: "chat6", userId: 12)
        let chat7 = ChatModel(text: "chat7", userId: 13)
        let chat8 = ChatModel(text: "chat8", userId: 13)
        
        XCTAssertNoThrow(try ChatModel.insert(models: [chat1,chat2,chat3,chat4,chat5,chat6,chat7,chat8]))
        
        var chats = ChatModel.queryAll().run()
        XCTAssertEqual(chats.count, 8)
        
        chats = ChatModel.query("userId", "=", 12).run()
        XCTAssertEqual(chats.count, 6)
        
        chats = ChatModel.query("userId", "=", 13).run()
        XCTAssertEqual(chats.count, 2)
        
        
        
    }
    
    
    /// Go to UserModel and comment/uncomment corresponding codes !!!!
    func testMigrating_B() {
        try! UserModel.migrate(ToVersion: 1) { (migrator, property) in
            
            if property == "chatMsgCount" {
                let sql = "UPDATE \(migrator.newTableName) SET \(property) = (SELECT count(*) FROM ChatModel WHERE \(ChatModel.tableName()).userId = \(migrator.newTableName).\(migrator.primaryKey))"
                migrator.runRawSQL(sql: sql)
            }
            
        }
        
        let user1 = UserModel.query(byPrimaryKey: 12)
        let user2 = UserModel.query(byPrimaryKey: 13)
        XCTAssertNotNil(user1)
        XCTAssertNotNil(user2)
        XCTAssertEqual(user1!.chatMsgCount, 6)
        XCTAssertEqual(user2!.chatMsgCount, 2)
    }
    
    
    func testMigration() {
        //######################## FIRST RUN #######################
        //#### 0. reset
//        try! MigrationModel.deleteAll()
//        
//        MigrationModel.clearArchivedColumnInfo()
//
//        //#### 1. first launch
//        let m0  = MigrationModel(id: 23, firstName: "fisrt_1", lastName: "last_1")
//        let m1  = MigrationModel(id: 33, firstName: "fisrt_2", lastName: "last_2")
//        let m2  = MigrationModel(id: 54, firstName: "fisrt_3", lastName: "last_3")
//        let m3  = MigrationModel(id: 75, firstName: "fisrt_4", lastName: "last_4")
//        XCTAssertNoThrow(try MigrationModel.insert(models: [m0,m1,m2,m3]))
        
        //######################## SECOND RUN #######################
//        MigrationModel.queryAll()
        
//        MigrationModel.queryAll()
        
    }
    
    
    func testShouldArchiveColumn() {
        //#### 0. reset
//        MigrationModel.clearArchivedColumnInfo()
        
        //#### 1. first launch
//        XCTAssertFalse(MigrationModel.shouldMigrate())
//        MigrationModel.archive(forVersion: 0)
        
        
        //#### 2. change columnInfo, then test the followings
//        XCTAssertTrue(MigrationModel.shouldMigrate())
        
        
        
        
        //#### 3.
        
        
//        XCTAssertTrue(MigrationModel.shouldMigrate())
        
        
    }
    
    
    func testColumnInfoInDisk() {
//        AHDBColumnInfo.clearArchives()
//        let info1 = Master.columnInfo()
//        AHDBColumnInfo.archive(columns: info1, forVersion: 1)
//        let info11 = AHDBColumnInfo.unarchive(forVersion: 1)
//        XCTAssertEqual(info11, info1)
//        
//        let info22 = AHDBColumnInfo.unarchive(forVersion: 2)
//        XCTAssertEqual(info22.count, 0)
//        
//        
//        AHDBColumnInfo.archive(columns: info1, forVersion: 3)
//        let info111 = AHDBColumnInfo.unarchive(forVersion: 3)
//        XCTAssertEqual(info1, info111)
        
        
    }
    
    
    func testColumnInfo() {
        let primary1 = AHDBColumnInfo(name: "id", type: .integer, constraints: "primary key")
        let primary2 = AHDBColumnInfo(name: "id", type: .integer, constraints: "PRIMARY key")
        let primary3 = AHDBColumnInfo(name: "id", type: .text, constraints: "PRIMARY key")
        XCTAssert(primary1 == primary2)
        XCTAssertNotEqual(primary1, primary3)
        XCTAssertNotEqual(primary2, primary3)
        

        
        let age1 = AHDBColumnInfo(name: "age", type: .integer, constraints: "not null")
        let age2 = AHDBColumnInfo(name: "age", type: .integer)
        let age3 = AHDBColumnInfo(name: "age", type: .integer, constraints: "")
        let age4 = AHDBColumnInfo(name: "--age", type: .integer, constraints: "not null")
        XCTAssert(age2 == age3)
        XCTAssertNotEqual(age1, age2)
        XCTAssertNotEqual(age1, age4)
        
        
        
        
        let score1 = AHDBColumnInfo(name: "score", type: .real)
        let score2 = AHDBColumnInfo(name: "score", type: .text)
        let score3 = AHDBColumnInfo(name: "score", type: .integer)
        XCTAssertNotEqual(score1, score2)
        XCTAssertNotEqual(score1, score3)
        XCTAssertNotEqual(score2, score3)
        
        
        
        
        
        let foreginKey1 = AHDBColumnInfo(foreginKey: "masterId", type: .integer, referenceKey: "id", referenceTable: "Master")
        let foreginKey2 = AHDBColumnInfo(foreginKey: "MasteRID", type: .integer, referenceKey: "id", referenceTable: "MASTER")
        let foreginKey3 = AHDBColumnInfo(foreginKey: "masterId", type: .integer, referenceKey: "id", referenceTable: "DogModel")
        let foreginKey4 = AHDBColumnInfo(foreginKey: "masterId", type: .text, referenceKey: "id", referenceTable: "Master")
        let foreginKey5 = AHDBColumnInfo(foreginKey: "aaa", type: .integer, referenceKey: "id", referenceTable: "Master")
        XCTAssertEqual(foreginKey1,foreginKey2)
        XCTAssertNotEqual(foreginKey1, foreginKey3)
        XCTAssertNotEqual(foreginKey4, foreginKey5)
        
        
    }
    
}















