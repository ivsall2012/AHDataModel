//
//  AHDBColumnInfo.swift
//  Pods
//
//  Created by Andy Tong on 9/21/17.
//
//

import Foundation

/// This struct describes a column's infomations when created
public struct AHDBColumnInfo: Equatable {
    var name: String
    var type: AHDBDataType
    var isPrimaryKey = false
    var isForeignKey = false
    
    /// The key the foreign key is referring to
    var referenceKey: String = ""
    /// The foregin table's name
    var referenceTable: String = ""
    
    private(set) var constraints: [String] = [String]()
    
    
    /// This init method is used to add foregin key for this table
    ///
    /// - Parameters:
    ///   - foreginKey: the foregin key's name in this table
    ///   - type: the type should be the same as the one in the foreign table
    ///   - referenceKey: the name that foreginKey is referring to in the foreign table
    ///   - referenceTable: foreign table's name
    public init(foreginKey: String, type: AHDBDataType, referenceKey: String, referenceTable: String) {
        self.name = foreginKey
        self.referenceKey = referenceKey.lowercased()
        self.referenceTable = referenceTable.lowercased()
        self.isForeignKey = true
        self.type = type
    }
    
    
    public init(name: String, type: AHDBDataType, constraints: String... ) {
        self.name = name
        self.type = type
        for constraint in constraints {
            guard constraint.characters.count > 0 else {
                continue
            }
            let lowercased = constraint.lowercased()
            if lowercased.contains("primary key") {
                isPrimaryKey = true
            }
            self.constraints.append(lowercased)
        }
    }
    
    public init(name: String, type: AHDBDataType) {
        self.name = name
        self.type = type
    }
    
    public var bindingSql: String {
        if isForeignKey {
            let constraintString = constraints.joined(separator: " ")
            return "\(name) \(type.rawValue) \(constraintString) REFERENCES \(referenceTable)(\(referenceKey)) ON UPDATE CASCADE ON DELETE CASCADE"
        }else{
            let constraintString = constraints.joined(separator: " ")
            return "\(name) \(type.rawValue) \(constraintString)"
        }
    }
    
    public static func ==(lhs: AHDBColumnInfo, rhs: AHDBColumnInfo) -> Bool {
        let b1 = lhs.name == rhs.name && lhs.type == rhs.type && lhs.isPrimaryKey == rhs.isPrimaryKey && lhs.referenceKey == rhs.referenceKey && lhs.referenceTable == rhs.referenceTable && lhs.constraints.count == rhs.constraints.count
        
        if b1 {
            for constraint in lhs.constraints {
                if rhs.constraints.contains(constraint) == false {
                    return false
                }
            }
            
            for constraint in rhs.constraints {
                if lhs.constraints.contains(constraint) == false {
                    return false
                }
            }
            return true
        }
        
        return false
    }
    
    
    
    
    
    //    var name: String
    //    var type: AHDBDataType
    //    var isPrimaryKey = false
    //    var isForeignKey = false
    //
    //    var referenceKey: String = ""
    //    var referenceTable: String = ""
    //
    //    private(set) var constraints: [String] = [String]()
    
    //    public func encode(with aCoder: NSCoder) {
    //
    //    }
    //
    //    public init?(coder aDecoder: NSCoder){
    //        self.name = aDecoder.value(forKey: "")
    //    }
    
}
