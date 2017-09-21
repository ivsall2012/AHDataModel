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
        try! UserModel.deleteAll()
        try! Master.deleteAll()
        try! Dog.deleteAll()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        try! UserModel.deleteAll()
        try! Master.deleteAll()
        try! Dog.deleteAll()
        
    }
    
    func testUpdate() {
        let master  = Master(id: 1, age: 12, score: 213.2, name: "master_1")
        let master1  = Master(id: 122, age: 12, score: 213.2, name: "master_1")
        XCTAssertTrue(master.save())
        XCTAssertTrue(master1.save())
        
        let dog1 = Dog(masterId: master.id, name: "dog_1", age: 12)
        XCTAssertTrue(dog1.save())
        var dog2 = Dog(masterId: master.id, name: "dog_2", age: 12)
        XCTAssertTrue(dog2.save())
        let dog3 = Dog(masterId: master.id, name: "dog_3", age: 12)
        XCTAssertTrue(dog3.save())
        
        dog2.masterId = 122
        dog2.age = 42
        try! Dog.update(model: dog2, forProperties: ["masterId", "age"])
        
        let dog22 = Dog.query(byPrimaryKey: dog2.name)
        XCTAssertNotNil(dog22)
        XCTAssertEqual(dog2, dog22)
        
    }
    
    
    func testQuery() {
        let master  = Master(id: 1, age: 12, score: 213.2, name: "master_1")
        XCTAssertTrue(master.save())
        
        let dog1 = Dog(masterId: master.id, name: "dog_1", age: 12)
        XCTAssertTrue(dog1.save())
        let dog2 = Dog(masterId: master.id, name: "dog_2", age: 13)
        XCTAssertTrue(dog2.save())
        let dog3 = Dog(masterId: master.id, name: "dog_3", age: 14)
        XCTAssertTrue(dog3.save())
        
        
        var results = Dog.query(byFilters: (attribute: "name", operator: "LIKE", value: "dog%"))
        XCTAssertTrue(results.contains(dog1))
        XCTAssertTrue(results.contains(dog2))
        XCTAssertTrue(results.contains(dog3))
        
        results = Dog.query(byFilters: (attribute: "age", operator: ">=", value: 13))
        XCTAssertTrue(results.contains(dog2))
        XCTAssertTrue(results.contains(dog3))
    }
    
    
    func testMerge() {
        let userInfoA = UserModel(id: 12, name: "Andy", age: 25, address: "Las Vegas", phone: "702702702")
        let userInfoB = UserModel(id: 12, score: 33.2, isVIP: true, balance: 99999.99, position: nil)
        var expectUserInfoAB = UserModel(id: 12, name: "Andy", age: 25, address: "Las Vegas", phone: "702702702", score: 33.2, isVIP: true, balance: 99999.99, position: nil)
        
        
        let resultInfoAB = userInfoA.merge(model: userInfoB)
        XCTAssertTrue(resultInfoAB.save())
        XCTAssertEqual(resultInfoAB,expectUserInfoAB)
        
        let userInfoAB1 = UserModel.query(byPrimaryKey: 12)
        XCTAssertNotNil(userInfoAB1)
        XCTAssertEqual(userInfoAB1!, expectUserInfoAB)
        
        expectUserInfoAB.name = nil
        expectUserInfoAB.balance = nil
        XCTAssertTrue(expectUserInfoAB.save())
        let expectUserInfoAB1 = UserModel.query(byPrimaryKey: 12)
        XCTAssertNil(expectUserInfoAB1?.name)
        XCTAssertNil(expectUserInfoAB1?.balance)
        
    }
    
    func testNull() {
        let master  = Master(id: 1, age: 12, score: 213.2, name: "master_1")
        XCTAssertTrue(master.save())
        
        let dog1 = Dog(masterId: master.id, name: "dog_1", age: 12)
        XCTAssertTrue(dog1.save())
        let dog2 = Dog(masterId: master.id, name: "dog_2", age: 12)
        XCTAssertTrue(dog2.save())
        var dog3 = Dog(masterId: master.id, name: "dog_3", age: 12)
        XCTAssertTrue(dog3.save())
        
        
        var dogs = Dog.query(byFilters: (attribute: "masterId", operator: "=", value: master.id))
        XCTAssertEqual(dogs.count, 3)
        
        
        print("AAAAA \(Thread.current)")
        dog3.masterId = nil
        XCTAssertTrue(dog3.save())
        dogs = Dog.query(byFilters: (attribute: "name", operator: "=", value: "dog_3"))
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
        try! Master.insert(model: master)
        
        var dog1 = Dog(masterId: master.id, name: "dog_1", age: 12)
        var dog2 = Dog(masterId: master.id, name: "dog_2", age: 12)
        var dog3 = Dog(masterId: master.id, name: "dog_3", age: 12)
        
        try! Dog.insert(models: [dog1,dog2,dog3])
        
        
        
        var dogs = Dog.query(byFilters: (attribute: "masterId", operator: "=", value: master.id))
        XCTAssertEqual(dogs.count, 3)
        
        master.name = "master_2"
        master.age = 33
        try! Master.update(model: master)
        
        dog3.age = 33
        try! Dog.update(model: dog3)
        let dog33 = Dog.query(byPrimaryKey: "dog_3")
        XCTAssertNotNil(dog33)
        XCTAssert(dog3 == dog33)
        
        dog2.age = 21
        dog1.age = 11
        try! Dog.update(models: [dog2, dog1])
        let dog22 = Dog.query(byPrimaryKey: "dog_2")
        XCTAssertNotNil(dog22)
        XCTAssert(dog2 == dog22)
        
        var dog11 = Dog.query(byPrimaryKey: "dog_1")
        XCTAssertNotNil(dog11)
        XCTAssert(dog1 == dog11)
        
        
        var shouldFail = false
        dog11?.masterId = 999
        do {
            try Dog.update(models: [dog11!])
        } catch _ {
            shouldFail = true
        }
        XCTAssertTrue(shouldFail)
        let master_ = Master.query(byPrimaryKey: 1)
        XCTAssertNotNil(master_)
        
        XCTAssertTrue(master == master_)
        
        XCTAssertTrue(Master.modelExists(model: master_!))
        XCTAssertTrue(Master.modelExists(primaryKey: master_!.id))
        
        
        
        try! Dog.delete(model: dog2)
        try! Dog.delete(model: dog3)
        
        XCTAssertFalse(Dog.modelExists(model: dog2))
        XCTAssertFalse(Dog.modelExists(model: dog3))
        XCTAssertFalse(Dog.modelExists(primaryKey: dog3.name))
        
        dogs = Dog.query(byFilters: (attribute: "masterId", operator: "=", value: master.id))
        XCTAssertEqual(dogs.count, 1)
        
        dog11 = dogs.first
        XCTAssertNotNil(dog11)
        XCTAssert(dog1 == dog11)
        
        
        try! Dog.delete(model: dog1)
        
        dogs = Dog.query(byFilters: (attribute: "masterId", operator: "=", value: master.id))
        XCTAssertEqual(dogs.count, 0)
        
        var masters = Master.query(byFilters: (attribute: "id", operator: "=", value: master.id))
        XCTAssertEqual(masters.count, 1)
        
        try! Master.delete(model: master)
        
        masters = Master.query(byFilters: (attribute: "id", operator: "=", value: master.id))
        XCTAssertEqual(masters.count, 0)
        
    }
    
}
