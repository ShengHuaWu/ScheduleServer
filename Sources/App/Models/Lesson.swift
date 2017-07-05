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
    
    // Use these keys instead of magic strings
    static let idKey = "id"
    static let titleKey = "title"
    
    init(title: String) {
        self.title = title
    }
    
    init(row: Row) throws {
        self.title = try row.get(Lesson.titleKey)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Lesson.titleKey, title)
        return row
    }
}

// For database prepare and revert
extension Lesson: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { (user) in
            user.id()
            user.string(Lesson.titleKey)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// Convenience of generate model from JSON
extension Lesson: JSONConvertible {
    convenience init(json: JSON) throws {
        self.init(title: try json.get(Lesson.titleKey))
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Lesson.idKey, id?.string)
        try json.set(Lesson.titleKey, title)
        return json
    }
}

// Convenience of returning response
extension Lesson: ResponseRepresentable {}
