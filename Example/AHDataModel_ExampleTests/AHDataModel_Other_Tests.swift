//
//  AHDataModel_Other_Tests.swift
//  AHDataModel
//
//  Created by Andy Tong on 9/21/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
import AHDataModel


class AHDataModel_Other_Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testColumnInfoInDisk() {
        
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















