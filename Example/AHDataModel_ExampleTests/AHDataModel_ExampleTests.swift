//
//  AHDataModel_ExampleTests.swift
//  AHDataModel_ExampleTests
//
//  Created by Andy Tong on 9/20/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
import AHDataModel

class AHDataModel_ExampleTests: XCTestCase {
    
    override func setUp() {
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
        
        try! UserModel.deleteAll()
        try! Master.deleteAll()
        try! Dog.deleteAll()
        try! ChatModel.deleteAll()
    }
    
    
    func testTransaction() {
        do {
            try ChatModel.transaction {
                let userInfoA = UserModel(id: 12, name: "Andy", age: 25, address: "Las Vegas", phone: "702702702")
                let userInfoB = UserModel(id: 55, name: "Chris", age: 35, address: "BeiJing", phone: "+86010......")
                XCTAssertNoThrow(try UserModel.insert(model: userInfoA))
                XCTAssertNoThrow(try UserModel.insert(model: userInfoB))
                
                let chat1 = ChatModel(text: "There's a place ... chat_1", userId: 12)
                let chat2 = ChatModel(text: "in your heart ... chat_2", userId: 55)
                let chat3 = ChatModel(text: "and I know that ... chat_3", userId: 12)
                
                XCTAssert(ChatModel.insert(models: [chat1,chat2,chat3]).count == 0)
                throw AHDBError.other(message: "transaction exception!!")
            }
        } catch _ {
            // test if rollback takes effect
            let chats = ChatModel.queryAll().run()
            XCTAssertEqual(chats.count, 0)
            let users = UserModel.queryAll().run()
            XCTAssertEqual(users.count, 0)
            return
        }
        XCTAssert(false)
    }
    
    
    
    /// If your model ignores id primary key then they don't have a system assigned IDs untill you query them back from the database.
    /// After you query them back and they all have their own IDs, then you can update them as usual.
    func testNotSetPrimaryKey_2() {
        let userInfoA = UserModel(id: 12, name: "Andy", age: 25, address: "Las Vegas", phone: "702702702")
        let userInfoB = UserModel(id: 55, name: "Chris", age: 35, address: "BeiJing", phone: "+86010......")
        XCTAssertNoThrow(try UserModel.insert(model: userInfoA))
        XCTAssertNoThrow(try UserModel.insert(model: userInfoB))
        
        
        let chat1 = ChatModel(text: "There's a place ... chat_1", userId: 12)
        let chat2 = ChatModel(text: "in your heart ... chat_2", userId: 55)
        let chat3 = ChatModel(text: "and I know that ... chat_3", userId: 12)
        let chat4 = ChatModel(text: "it is ... chat_4", userId: 55)
        let chat5 = ChatModel(text: "love ... chat_5", userId: 12)
        XCTAssert(ChatModel.insert(models: [chat1,chat2,chat3,chat4,chat5]).count == 0)
        
        // now those chat models have their own IDs assigned by Sqlite
        var chats = ChatModel.query("userId", "=", 12).run()
        XCTAssertEqual(chats.count, 3)
        
        chats = ChatModel.query("userId", "=", 55).OrderBy("userId", isASC: true).run()
        XCTAssertEqual(chats.count, 2)
        
        // now since chats contains models with IDs, we can update them as usual
        for chat in chats {
            var chat = chat
            chat.text = "aaa"
            XCTAssertNoThrow(try ChatModel.update(model: chat))
        }
        
        chats = ChatModel.query("userId", "=", 55).OrderBy("userId", isASC: true).run()
        XCTAssertEqual(chats.count, 2)
        XCTAssertEqual(chats[0].text, "aaa")
        XCTAssertEqual(chats[1].text, "aaa")
        
        
        
        
        // foregin key tests
        XCTAssertNoThrow(try UserModel.delete(model: userInfoA))
    
        chats = ChatModel.query("userId", "=", 12).run()
        XCTAssertEqual(chats.count, 0)
    
        chats = ChatModel.query("userId", "=", 55).run()
        XCTAssertEqual(chats.count, 2)
        
    }
    
    func testNotSetPrimaryKey_1() {
        // no primary key id
        let master0  = Master(age: 12, score: 45, name: "fun_1")
        let master1  = Master(age: 22, score: 55, name: nil)
        let master2  = Master(age: 33, score: 65, name: "fun_2")
        let master3  = Master(age: nil, score: 75, name: "master_3")
        
        // with primary key id
        let master4 = Master(id: 55, age: nil, score: 85, name: nil)
        let master5  = Master(id: 66, age: 66, score: 95, name: nil)
        let master6  = Master(id: 76, age: nil, score: 123, name: "fun_6")
        let master7  = Master(id: 87, age: 88, score: 234, name: "fun_7")
        
        XCTAssert(Master.insert(models: [master0,master1,master2,master3,master4,master5,master6,master7]).count == 0)
        
        var masters = Master.queryAll().run()
        XCTAssertEqual(masters.count, 8)
        
        masters = Master.query("age", "<=", 35).OrderBy("age", isASC: true).run()
        XCTAssertEqual(masters.count, 3)
        XCTAssertEqual(masters[0].age, 12)
        XCTAssertEqual(masters[1].age, 22)
        XCTAssertEqual(masters[2].age, 33)
        
        XCTAssertNoThrow(try Master.delete(models: masters))
        
        masters = Master.query("age", "<=", 35).OrderBy("age", isASC: true).run()
        XCTAssertEqual(masters.count, 0)
        
    }
    
    
    func testRawSQL() {
        let master0  = Master(id: 1, age: 12, score: 45, name: "fun_1")
        let master1  = Master(id: 2, age: 22, score: 55, name: nil)
        let master2  = Master(id: 3, age: 33, score: 65, name: "fun_2")
        let master3  = Master(id: 4, age: nil, score: 75, name: "master_3")
        let master4 = Master(id: 5, age: nil, score: 85, name: nil)
        let master5  = Master(id: 6, age: 66, score: 95, name: nil)
        let master6  = Master(id: 7, age: nil, score: 123, name: "fun_6")
        let master7  = Master(id: 8, age: 88, score: 234, name: "fun_7")
        
        XCTAssert(Master.insert(models: [master0,master1,master2,master3,master4,master5,master6,master7]).count == 0)
        
        let masters = Master.queryWhere(rawSQL: "id >= ? AND age <= ?", values: [5, 88])
        XCTAssertEqual(masters.count, 2)
        
    }
    
    func testCompositeQuery_2() {
        let master0  = Master(id: 1, age: 12, score: 45, name: "fun_1")
        let master1  = Master(id: 2, age: 22, score: 55, name: nil)
        let master2  = Master(id: 3, age: 33, score: 65, name: "fun_2")
        let master3  = Master(id: 4, age: nil, score: 75, name: "master_3")
        let master4 = Master(id: 5, age: nil, score: 85, name: nil)
        let master5  = Master(id: 6, age: 66, score: 95, name: nil)
        let master6  = Master(id: 7, age: nil, score: 123, name: "fun_6")
        let master7  = Master(id: 8, age: 88, score: 234, name: "fun_7")
        
        XCTAssert(Master.insert(models: [master0,master1,master2,master3,master4,master5,master6,master7]).count == 0)
        
        var masters = Master.queryAll().run()
        XCTAssertEqual(masters.count, 8)
        
        // 3 nil ages being skipped!
        
        masters = Master.query("age", "IS NOT", nil).run()
        XCTAssertEqual(masters.count, 5)
        
        masters = Master.query("age", "IS", nil).run()
        XCTAssertEqual(masters.count, 3)
        
        masters = Master.query("name", "IS", nil).run()
        XCTAssertEqual(masters.count, 3)
        
        masters = Master.query("age", "IN", [33,66,88]).run()
        XCTAssertEqual(masters.count, 3)
        
        // 3 nil ages being skipped!
        masters = Master.query("age", "NOT IN", [33,66,88]).run()
        XCTAssertEqual(masters.count, 2)
        
        // below causes fatalError
//        masters = Master.query(byFilters: ("age", "fsafsa", [33,66,88])).run()
        
        
        
        // Testing 'Limit'
        masters = Master.queryAll().OrderBy("id", isASC: false).Limit(2).run()
        XCTAssertEqual(masters.count, 2)
        XCTAssertEqual(masters[0].id, 8)
        XCTAssertEqual(masters[1].id, 7)
        
        
        masters = Master.queryAll().OrderBy("id", isASC: false).Limit(3, offset: 2).run()
        XCTAssertEqual(masters.count, 3)
        XCTAssertEqual(masters[0].id, 6)
        XCTAssertEqual(masters[1].id, 5)
        XCTAssertEqual(masters[2].id, 4)
        
        
        
        masters = Master.queryAll().OrderBy("id", isASC: false).Limit(2, offset: 6).run()
        XCTAssertEqual(masters.count, 2)
        XCTAssertEqual(masters[0].id, 2)
        XCTAssertEqual(masters[1].id, 1)
        
        // Limit is out of bound
        masters = Master.queryAll().OrderBy("id", isASC: false).Limit(5, offset: 6).run()
        XCTAssertEqual(masters.count, 2)
        XCTAssertEqual(masters[0].id, 2)
        XCTAssertEqual(masters[1].id, 1)
        
        // Offset is out of bound
        masters = Master.queryAll().OrderBy("id", isASC: false).Limit(5, offset: 10).run()
        XCTAssertEqual(masters.count, 0)
        
    }
    func testCompositeQuery_1() {
        let master0  = Master(id: 1, age: 12, score: 45, name: "fun_1")
        let master1  = Master(id: 2, age: 22, score: 55, name: "master_2")
        let master2  = Master(id: 3, age: 33, score: 65, name: "fun_2")
        let master3  = Master(id: 4, age: 44, score: 75, name: "master_3")
        let master4 = Master(id: 5, age: 55, score: 85, name: "fun_4")
        let master5  = Master(id: 6, age: 66, score: 95, name: "fun_5")
        let master6  = Master(id: 7, age: 77, score: 123, name: "fun_6")
        let master7  = Master(id: 8, age: 88, score: 234, name: "fun_7")
        
        XCTAssert(Master.insert(models: [master0,master1,master2,master3,master4,master5,master6,master7]).count == 0)
        
        var masters = Master.queryAll().run()
        XCTAssertEqual(masters.count, 8)
        
        // Testing 'AND'
        masters = Master.query("age", ">", 22).AND("score", "<", 85).run()
        XCTAssertEqual(masters.count, 2)
        
        // Testing 'AND', 'OrderBy'
        masters = Master.query("name", "LIKE", "fun%").AND("age", "<=", "77").AND("score", ">", 65).OrderBy("score", isASC: false).run()
        XCTAssertEqual(masters.count, 3)
        XCTAssertEqual(masters[0].score, 123)
        XCTAssertEqual(masters[1].score, 95)
        XCTAssertEqual(masters[2].score, 85)
        
        
        // Testing 'AND', 'OrderBy', 'OR'
        masters = Master.query("id", ">", 5).OR("score", "<", 85).AND("age", ">=", 33).OrderBy("id", isASC: false).run()
        
        XCTAssertEqual(masters.count, 5)
        XCTAssertEqual(masters[0].id, 8)
        XCTAssertEqual(masters[1].id, 7)
        XCTAssertEqual(masters[2].id, 6)
        XCTAssertEqual(masters[3].id, 4)
        XCTAssertEqual(masters[4].id, 3)
        
        
    }
    
    
    func testUpdate() {
        let master  = Master(id: 1, age: 12, score: 213.2, name: "master_1")
        let master1  = Master(id: 122, age: 12, score: 213.2, name: "master_1")
        XCTAssertNoThrow(try Master.insert(model: master))
        XCTAssertNoThrow(try Master.insert(model: master1))
        
        let dog1 = Dog(masterId: master.id, name: "dog_1", age: 12)
        var dog2 = Dog(masterId: master.id, name: "dog_2", age: 12)
        let dog3 = Dog(masterId: master.id, name: "dog_3", age: 12)
       XCTAssert(Dog.insert(models: [dog1,dog2,dog3]).count == 0)
        
        dog2.masterId = 122
        dog2.age = 42
        try! Dog.update(model: dog2, forProperties: ["masterId", "age"])
        
        let dog22 = Dog.query(byPrimaryKey: dog2.name)
        XCTAssertNotNil(dog22)
        XCTAssertEqual(dog2, dog22)
        
    }
    
    
    func testQuery() {
        let master  = Master(id: 1, age: 12, score: 213.2, name: "master_1")
        XCTAssertNoThrow(try Master.insert(model: master))
        
        let dog1 = Dog(masterId: master.id, name: "dog_1", age: 12)
        let dog2 = Dog(masterId: master.id, name: "dog_2", age: 13)
        let dog3 = Dog(masterId: master.id, name: "dog_3", age: 14)
        
        XCTAssert(Dog.insert(models: [dog1,dog2,dog3]).count == 0)
        
        var results = Dog.query("name", "LIKE", "dog%").run()
        XCTAssertTrue(results.contains(dog1))
        XCTAssertTrue(results.contains(dog2))
        XCTAssertTrue(results.contains(dog3))
        
        results = Dog.query("age", ">=", 13).run()
        XCTAssertTrue(results.contains(dog2))
        XCTAssertTrue(results.contains(dog3))
    }
    
    
//    func testMerge() {
//        let userInfoA = UserModel(id: 12, name: "Andy", age: 25, address: "Las Vegas", phone: "702702702")
//        let userInfoB = UserModel(id: 12, score: 33.2, isVIP: true, balance: 99999.99, position: nil)
//        var expectUserInfoAB = UserModel(id: 12, name: "Andy", age: 25, address: "Las Vegas", phone: "702702702", score: 33.2, isVIP: true, balance: 99999.99, position: nil, chatMsgCount: nil)
//
//        let resultInfoAB = userInfoA.merge(model: userInfoB)
//        XCTAssertTrue(resultInfoAB.save())
//        XCTAssertEqual(resultInfoAB,expectUserInfoAB)
//
//        let userInfoAB1 = UserModel.query(byPrimaryKey: 12)
//        XCTAssertNotNil(userInfoAB1)
//        XCTAssertEqual(userInfoAB1!, expectUserInfoAB)
//
//        expectUserInfoAB.name = nil
//        expectUserInfoAB.balance = nil
//        XCTAssertTrue(expectUserInfoAB.save())
//        let expectUserInfoAB1 = UserModel.query(byPrimaryKey: 12)
//        XCTAssertNil(expectUserInfoAB1?.name)
//        XCTAssertNil(expectUserInfoAB1?.balance)
//
//    }
    
//    func testNull() {
//        let master  = Master(id: 1, age: 12, score: 213.2, name: "master_1")
//        XCTAssertTrue(master.save())
//
//        let dog1 = Dog(masterId: master.id, name: "dog_1", age: 12)
//        XCTAssertTrue(dog1.save())
//        let dog2 = Dog(masterId: master.id, name: "dog_2", age: 12)
//        XCTAssertTrue(dog2.save())
//        var dog3 = Dog(masterId: master.id, name: "dog_3", age: 12)
//        XCTAssertTrue(dog3.save())
//
//
//        var dogs = Dog.query("masterId", "=", master.id).run()
//        XCTAssertEqual(dogs.count, 3)
//
//
//        dog3.masterId = nil
//        XCTAssertTrue(dog3.save())
//        dogs = Dog.query("name", "=", "dog_3").run()
//        XCTAssertEqual(dogs.count, 1)
//        let dog33 = dogs.first!
//        XCTAssertEqual(dog3, dog33)
//        XCTAssertNil(dog33.masterId)
//
//        // would crush, since name is dog's primary key, ok
//        //        dog2.name = nil
//        //        dog2.save()
//    }
    
    func testNull() {
        let master  = Master(id: 1, age: 12, score: 213.2, name: "master_1")
        XCTAssertNoThrow(try Master.insert(model: master))
        
        let dog1 = Dog(masterId: master.id, name: "dog_1", age: 12)
        let dog2 = Dog(masterId: master.id, name: "dog_2", age: 12)
        var dog3 = Dog(masterId: master.id, name: "dog_3", age: 12)
        
        XCTAssert(Dog.insert(models: [dog1,dog2,dog3]).count == 0)
        
        var dogs = Dog.query("masterId", "=", master.id).run()
        XCTAssertEqual(dogs.count, 3)
        
        
        dog3.masterId = nil
        XCTAssertNoThrow(try Dog.update(model: dog3))
        dogs = Dog.query("name", "=", "dog_3").run()
        XCTAssertEqual(dogs.count, 1)
        let dog33 = dogs.first!
        XCTAssertEqual(dog3, dog33)
        XCTAssertNil(dog33.masterId)
        
        // would crush, since name is dog's primary key, ok
        //        dog2.name = nil
        //        dog2.save()
    }
    
    
    func testBasics() {
        var master  = Master(id: 1, age: 12, score: 213.2, name: "master_1")
        XCTAssertNoThrow(try Master.insert(model: master))
        
        var dog1 = Dog(masterId: master.id, name: "dog_1", age: 12)
        var dog2 = Dog(masterId: master.id, name: "dog_2", age: 12)
        var dog3 = Dog(masterId: master.id, name: "dog_3", age: 12)
        
        XCTAssert(Dog.insert(models: [dog1,dog2,dog3]).count == 0)
        
        
        
        var dogs = Dog.query("masterId", "=", master.id).run()
        XCTAssertEqual(dogs.count, 3)
        
        master.name = "master_2"
        master.age = 33
        XCTAssertNoThrow(try Master.update(model: master))
        
        dog3.age = 33
        XCTAssertNoThrow(try Dog.update(model: dog3))
        let dog33 = Dog.query(byPrimaryKey: "dog_3")
        XCTAssertNotNil(dog33)
        XCTAssert(dog3 == dog33)
        
        dog2.age = 21
        dog1.age = 11
        XCTAssert(Dog.update(models: [dog2, dog1]).count == 0)
        let dog22 = Dog.query(byPrimaryKey: "dog_2")
        XCTAssertNotNil(dog22)
        XCTAssert(dog2 == dog22)
        
        var dog11 = Dog.query(byPrimaryKey: "dog_1")
        XCTAssertNotNil(dog11)
        XCTAssert(dog1 == dog11)
        
        
        dog11?.masterId = 999
        
        XCTAssertThrowsError(try Dog.update(model: dog11!))

        let master_ = Master.query(byPrimaryKey: 1)
        XCTAssertNotNil(master_)
        
        XCTAssertTrue(master == master_)
        
        XCTAssertTrue(Master.modelExists(model: master_!))
        XCTAssertTrue(Master.modelExists(primaryKey: master_!.id!))
        
        
        
        XCTAssertNoThrow(try Dog.delete(model: dog2))
        XCTAssertNoThrow(try Dog.delete(model: dog3))
        
        XCTAssertFalse(Dog.modelExists(model: dog2))
        XCTAssertFalse(Dog.modelExists(model: dog3))
        XCTAssertFalse(Dog.modelExists(primaryKey: dog3.name))
        
        dogs = Dog.query("masterId", "=", master.id).run()
        XCTAssertEqual(dogs.count, 1)
        
        dog11 = dogs.first
        XCTAssertNotNil(dog11)
        XCTAssert(dog1 == dog11)
        
        
        XCTAssertNoThrow(try Dog.delete(model: dog1))
        
        dogs = Dog.query("masterId", "=", master.id).run()
        XCTAssertEqual(dogs.count, 0)
        
        var masters = Master.query("id", "=", master.id).run()
        XCTAssertEqual(masters.count, 1)
        
        XCTAssertNoThrow(try Master.delete(model: master))
        
        masters = Master.query("id", "=", master.id).run()
        XCTAssertEqual(masters.count, 0)
    }
    
}
