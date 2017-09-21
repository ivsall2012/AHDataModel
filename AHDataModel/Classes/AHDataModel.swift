//
//  AHDBProtocols.swift
//  AHDB2
//
//  Created by Andy Tong on 7/3/17.
//  Copyright © 2017 Andy Tong. All rights reserved.
//


/// This struct acts as a storage for the protocol
private struct AHDBHelper {
    /// [modelName: isSetup]
    static var isSetupDict = [String: Bool]()
}

/// Methods to be conformed.
/// Note: You should always specify primary key in columnInfo() since currently the protocol only supports models with primary keys.
public protocol AHDataModel {
    static func databaseFilePath() -> String
    static func columnInfo() -> [AHDBColumnInfo]
//    static func initModel(with dict: [String: Any]) -> Self
    init(with dict: [String: Any])
    static func tableName() -> String
    
    /// return [propertyStr: value], propertyStr is the property/column names used in both the object(or struct) and the database. 
    /// So the Swift property names and dtabase column names should be the same.
    func toDict() -> [String: Any]
}

/// Public Instance Methods
extension AHDataModel {
    public func delete() -> Bool {
        do {
            try Self.delete(model: self)
        } catch _ {
            return false
        }
        return true
    }
    
    public func save() -> Bool {
        do {
            // If update failed, then go insert
            if Self.modelExists(model: self) {
                try Self.update(model: self)
            }else {
                try Self.insert(model: self)
            }
        } catch _ {
            return false
        }
        return true
        
    }
    
    /// The model passed in is the one overriding this model.
    /// Return a merged version of the two models.
    /// If shouldBeOverrided is true, this model instance's properties will be the same as the other one, which is really unnecessary, you should make a copy of it instead.
    /// shouldBeOverrided is false, this model's nil properties will be set if the other model's.
    /// shouldBeOverrided is false by default.
    @discardableResult
    public func merge(model: Self, shouldBeOverrided: Bool = false) -> Self{
        guard self.primaryKey() == model.primaryKey() else {
            preconditionFailure("Both models must have the same primary key")
        }
        let thisAttributes = self.attributes()
        let thatDict = model.toDict()
        
        var newAttributes = [AHDBAttribute]()
        for attr in thisAttributes {
            var attr_M = attr
            if attr_M.value == nil {
                attr_M.value = thatDict[attr.key]
            }
            newAttributes.append(attr_M)
        }
        let dict = Self.rowToDict(attributes: newAttributes)
        let model = Self(with: dict)
        return model
    }
}


/// Public Static Methods
extension AHDataModel {
    public static func delete(model: Self) throws {
        guard let db = Self.db else {
            throw AHDBError.other(message: "Internal error, db does not exist!")
        }
        setup()
        
        if let primaryKey = model.primaryKey() {
            try db.delete(tableName: Self.tableName(), primaryKey: primaryKey)
        }else{
            throw AHDBError.other(message: "\(Self.self) doens't have a primary key!!")
        }
    }
    
    public static func update(model: Self) throws {
        guard let db = Self.db else {
            throw AHDBError.other(message: "Internal error, db does not exist!")
        }

        setup()
        
        let attributes = model.attributes()
        if let primaryKey = model.primaryKey() {
            try db.update(tableName: Self.tableName(), bindings: attributes, primaryKey: primaryKey)
        }else{
            throw AHDBError.other(message: "\(Self.self) doens't have a primary key!!")
        }
    }
    
    /// not a transaction yet!
    public static func update(models: [Self]) throws {
        for model in models {
            try update(model: model)
        }
    }
    
    /// Update specific properties of this model into the database
    /// Note: This will override existing values.
    public static func update(model: Self, forProperties properties: [String]) throws {
        guard let db = Self.db else {
            throw AHDBError.other(message: "Internal error, db does not exist!")
        }
        setup()
        
        let keys = model.toDict().keys
        for key in properties {
            if keys.contains(key) == false {
                throw AHDBError.other(message: "\(Self.self) doesn't have key '\(key)'")
            }
        }
        
        let attributes = model.attributes().filter({ (attr) -> Bool in
            return properties.contains(attr.key)
        })
        
        if let primaryKey = model.primaryKey() {
            try db.update(tableName: Self.tableName(), bindings: attributes, primaryKey: primaryKey)
            return
        }else{
            throw AHDBError.other(message: "\(Self.self) doens't have a primary key!!")
        }
        
    }
    
    public static func insert(model: Self) throws {
        let attributes = model.attributes()
        guard let db = Self.db else {
            throw AHDBError.other(message: "Internal error, db does not exist!")
        }
        setup()
        try db.insert(table: Self.tableName(), bindings: attributes)
    }
    
    /// If return false, there must be at least 1 error. not a transaction yet!
    public static func insert(models: [Self]) throws {
        for model in models {
            try insert(model: model)
        }
    }
    
    public static func query(byFilters filters: (attribute: String,
        operator: String, value: Any)...) ->[Self] {
        guard let db = Self.db else {
            return []
        }
        setup()
        let tableName = Self.tableName()
        var attributes = [AHDBAttribute]()
        var sql: String = "SELECT * FROM \(tableName) WHERE "
        for (index, filter) in filters.enumerated() {
            let (attribute, operator_, value) = filter
            checkOperator(operator_)
            sql += "\(attribute) \(operator_) ?"
            if index != filters.count - 1 {
                sql += " AND "
            }
            let type = getValueType(value: value)
            let attr = AHDBAttribute(key: attribute, value: value, type: type)
            attributes.append(attr)
        }
        
        
        
        do {
            let results = try db.query(sql: sql, bindings: attributes)
            var models = [Self]()
            if results.count > 0 {
                for result in results {
                    let dict = rowToDict(attributes: result)
                    let model = Self(with: dict)
                    models.append(model)
                }
                return models
            }
        } catch let error{
            print("query error:\(error)")
        }
        
        return []
        
    }
    
    /// Pass the primaryKey and its value
    public static func query(byPrimaryKey primaryKey: Any) ->Self? {
        guard let db = Self.db else {
            return nil
        }
        setup()
        guard let keyName = primaryKeyName() else {return nil}
        let type = getValueType(value: primaryKey)
        let keyAttr = AHDBAttribute(key: keyName, value: primaryKey, type: type)
        let tableName = Self.tableName()
        
        do {
            let sql = "SELECT * FROM \(tableName) WHERE \(keyName) = ?"
            if let result = try db.query(sql: sql, bindings: [keyAttr]).first {
                let dict = rowToDict(attributes: result)
                return Self(with: dict)
            }
            
        } catch let error{
            print("get by primaryKey error:\(error)")
        }
        
        return nil
        
    }
    
    public static func modelExists(primaryKey: Any) -> Bool {
        if let _ = query(byPrimaryKey: primaryKey) {
            return true
        }else{
            return false
        }
    }
    
    public static func modelExists(model: Self) -> Bool {
        guard let _ = model.primaryKey() else {
            precondition(false, "model \(Self.self) must have a primary key!")
            return false
        }
        let keyValues = model.attributes().filter { (attr) -> Bool in
            return attr.isPrimaryKey
        }
        guard keyValues.count == 1 else {
            precondition(false, "model \(Self.self) must have a primary key!")
            return false
        }
        guard let keyValue = keyValues.first?.value else {
            precondition(false, "model \(Self.self)'s primary must not be nil")
            return false
        }
        return modelExists(primaryKey: keyValue)
        
    }
    
    
    /// Internally, it will drop the table containing the data model
    public static func deleteAll() throws {
        guard let db = Self.db else {
            return
        }
        guard db.tableExists(tableName: Self.tableName()) else {
            return
        }
        
        try db.deleteTable(name: Self.tableName())
        if let isSetup = AHDBHelper.isSetupDict[Self.modelName()],
            isSetup == true {
            AHDBHelper.isSetupDict[Self.modelName()] = false
        }
    }
    
}

/// Helper Mthods
extension AHDataModel {
    fileprivate static func getValueType(value: Any?) -> AHDBDataType? {
        if value == nil {
            return nil
        }
        var type: AHDBDataType?
        if value is Double || value is Float {
            type = .real
        }else if value is Int {
            type = .integer
        }else if value is String {
            type = .text
        }
        return type
    }
    fileprivate static func checkOperator(_ operator: String) {
        var todo: Any?
    }
    
    fileprivate static func modelName() -> String {
        return "\(Self.self)"
    }
    
    /// returns current key/value pair for the model, in [AHDBAttribute]
    fileprivate func attributes() -> [AHDBAttribute] {
        
        var attributeArray = [AHDBAttribute]()
        let attributeDict = self.toDict()
        
        for columnInfo in Self.columnInfo() {
            let name = columnInfo.name
            let type = columnInfo.type
            
            var value: Any?
            value = attributeDict[name]
            
            
            var attribute = AHDBAttribute(key: name, value: value, type: type)
            attribute.isPrimaryKey = columnInfo.isPrimaryKey
            attribute.isForeginKey = columnInfo.isForeignKey

            attributeArray.append(attribute)
            
            
        }
        
        return attributeArray
    }
    
    fileprivate func primaryKey() -> AHDBAttribute? {
        return attributes().filter { (attr) -> Bool in
            return attr.isPrimaryKey
            }.first
    }
    
    
    
    //### Static Methods
    
    fileprivate static func primaryKeyName() -> String? {
        for columnInfo in Self.columnInfo() {
            if columnInfo.isPrimaryKey {
                return columnInfo.name
            }
        }
        return nil
    }
    
}

/// Static Methods
extension AHDataModel {
    fileprivate static var db: AHDatabase? {
        let dbPath: String = Self.databaseFilePath()
        do {
            let db = try AHDatabase.connection(path: dbPath)
            return db
        }catch _ {
            return nil
        }
    }
    
    /// This method transform a series of 
    fileprivate static func rowToDict(attributes: [AHDBAttribute]) -> [String: Any] {
        // one row
        var modelDict = [String: Any]()
        for attribute in attributes {
            // one attribute
            modelDict[attribute.key] = attribute.value
        }
        return modelDict
    }
    
    /// Check if the table is being created or not
    fileprivate static func setup() {
        if let isSetup = AHDBHelper.isSetupDict[Self.modelName()],
            isSetup == true {
            return
        }
        guard let db = Self.db else {
            return
        }
        let info = Self.columnInfo()
        
        if db.tableExists(tableName: Self.tableName()) {
            //1. migration check
            
            //2. setup
            AHDBHelper.isSetupDict[Self.modelName()] = true
            return
        }else{
            try! db.createTable(tableName: Self.tableName(), columnInfoArr: info)
            AHDBHelper.isSetupDict[Self.modelName()] = true
        }

        
    }
    
}



public extension Bool {
    init?(_ value: Any?) {
        if let value = value as? Bool {
            self.init(value)
        }else{
            if let intValue = value as? Int, (intValue > 0 && intValue < 2) {
                self.init(intValue)
            }else{
                return nil
            }
        }
        
        
        
        
    }
    init?(_ number: Int) {
        if number < 0 || number > 1 {
            return nil
        }
        self.init(number as NSNumber)
    }
}




