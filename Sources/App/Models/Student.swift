//
//  Student.swift
//  ScheduleServer
//
//  Created by ShengHua Wu on 03/07/2017.
//
//

import PostgreSQLProvider

final class Student: Model {
    let storage = Storage()
    
    var name: String
    
    static let idKey = "id"
    static let nameKey = "name"
    
    init(name: String) {
        self.name = name
    }
    
    init(row: Row) throws {
        self.name = try row.get(Student.nameKey)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Student.nameKey, name)
        return row
    }
}

extension Student: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { (user) in
            user.id()
            user.string(Student.nameKey)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Student: JSONConvertible {
    convenience init(json: JSON) throws {
        self.init(name: try json.get(Student.nameKey))
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Student.idKey, id?.string)
        try json.set(Student.nameKey, name)
        return json
    }
}

extension Student: ResponseRepresentable {}
