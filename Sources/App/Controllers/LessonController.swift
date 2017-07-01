//
//  LessonController.swift
//  ScheduleServer
//
//  Created by ShengHua Wu on 01/07/2017.
//
//

import PostgreSQLProvider

final class LessonController {
    func addRoutes(droplet: Droplet) {
        let lessons = droplet.grouped("lessons")
        lessons.get("", handler: getAll)
        lessons.get(Int.parameter, handler: getOne)
        lessons.post("", handler: create)
        lessons.put(Int.parameter, handler: update)
        lessons.delete(Int.parameter, handler: delete)
    }
    
    private func getAll(request: Request) throws -> ResponseRepresentable {
        return try Lesson.all().makeJSON()
    }
    
    private func getOne(request: Request) throws -> ResponseRepresentable {
        let id = try request.parameters.next(Int.self)
        guard let lesson = try Lesson.makeQuery().filter("id", id).first() else {
            throw Abort.notFound
        }
        
        return lesson
    }
    
    private func create(request: Request) throws -> ResponseRepresentable {
        guard let title = request.data["title"]?.string else {
            throw Abort.badRequest
        }
        
        let lesson = Lesson(title: title)
        try lesson.save()
        return lesson
    }
    
    private func update(request: Request) throws -> ResponseRepresentable {
        let id = try request.parameters.next(Int.self)
        guard let lesson = try Lesson.makeQuery().filter("id", id).first() else {
            throw Abort.notFound
        }
        
        guard let title = request.data["title"]?.string else {
            throw Abort.badRequest
        }
        
        lesson.title = title
        try lesson.save()
        return lesson
    }
    
    private func delete(request: Request) throws -> ResponseRepresentable {
        let id = try request.parameters.next(Int.self)
        guard let lesson = try Lesson.makeQuery().filter("id", id).first() else {
            throw Abort.notFound
        }
        
        try lesson.delete()
        return lesson
    }
}
