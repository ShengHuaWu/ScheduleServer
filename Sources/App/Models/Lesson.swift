//
//  Class.swift
//  ScheduleServer
//
//  Created by ShengHua Wu on 29/06/2017.
//
//

import PostgreSQLProvider

final class Lesson: Model {
    let storage = Storage() // This is for Storable protocol
    
    var title: String
    
    init(title: String) {
        self.title = title
    }
    
    init(row: Row) throws {
        self.title = try row.get("title")
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("title", title)
        return row
    }
}

extension Lesson: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { (user) in
            user.id()
            user.string("title")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Lesson: JSONConvertible {
    convenience init(json: JSON) throws {
        self.init(title: try json.get("title"))
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id?.string)
        try json.set("title", title)
        return json
    }
}

extension Lesson: ResponseRepresentable {}
