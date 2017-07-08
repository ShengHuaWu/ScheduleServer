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
    var lessonId: Identifier? // Should use Identifier instead of Node
    
    static let idKey = "id"
    static let nameKey = "name"
    static let lessonIdKey = "lesson_id"
    
    init(name: String, lessonId: Identifier? = nil) {
        self.name = name
        self.lessonId = lessonId
    }
    
    init(row: Row) throws {
        self.name = try row.get(Teacher.nameKey)
        self.lessonId = try row.get(Teacher.lessonIdKey)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Teacher.nameKey, name)
        try row.set(Teacher.lessonIdKey, lessonId)
        return row
    }
}

extension Teacher: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { (user) in
            user.id()
            user.string(Teacher.nameKey)
            user.parent(Lesson.self, optional: false)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Teacher: JSONConvertible {
    convenience init(json: JSON) throws {
        let name: String = try json.get(Teacher.nameKey)
        let lessonId: Identifier? = try json.get(Teacher.lessonIdKey)
        self.init(name: name, lessonId: lessonId)
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Teacher.idKey, id?.string)
        try json.set(Teacher.nameKey, name)
        try json.set(Teacher.lessonIdKey, lessonId)
        return json
    }
}

extension Teacher: ResponseRepresentable {}
