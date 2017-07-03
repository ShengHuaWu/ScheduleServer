//
//  Teacher.swift
//  ScheduleServer
//
//  Created by ShengHua Wu on 03/07/2017.
//
//

import PostgreSQLProvider

final class Teacher: Model {
    let storage = Storage() // This is for Storable protocol
    
    var name: String
    
    static let idKey = "id"
    static let nameKey = "name"
    
    init(name: String) {
        self.name = name
    }
    
    init(row: Row) throws {
        self.name = try row.get(Teacher.nameKey)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Teacher.nameKey, name)
        return row
    }
}

extension Teacher: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { (user) in
            user.id()
            user.string(Teacher.nameKey)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Teacher: JSONConvertible {
    convenience init(json: JSON) throws {
        self.init(name: try json.get(Teacher.nameKey))
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Teacher.idKey, id?.string)
        try json.set(Teacher.nameKey, name)
        return json
    }
}

extension Teacher: ResponseRepresentable {}
