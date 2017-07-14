//
//  LessonController.swift
//  ScheduleServer
//
//  Created by ShengHua Wu on 01/07/2017.
//
//

import PostgreSQLProvider

final class LessonController {
    fileprivate func getAll(request: Request) throws -> ResponseRepresentable {
        return try Lesson.all().makeJSON()
    }
    
    fileprivate func getOne(request: Request, lesson: Lesson) throws -> ResponseRepresentable {
        return lesson
    }
    
    fileprivate func create(request: Request) throws -> ResponseRepresentable {
        let lesson = try request.lesson()
        try lesson.save()
        return lesson
    }
    
    fileprivate func update(request: Request, lesson: Lesson) throws -> ResponseRepresentable {
        let newLesson = try request.lesson()
        lesson.title = newLesson.title
        try lesson.save()
        return lesson
    }
    
    fileprivate func delete(request: Request, lesson: Lesson) throws -> ResponseRepresentable {
        try lesson.delete()
        return lesson
    }
    
    // TODO: Need refactoring
    func addRoutes(_ drop: Droplet) {
        let lessonsGroup = drop.grouped("lessons")
        lessonsGroup.get(Lesson.parameter, "teachers", handler: teachers)
    }
    
    private func teachers(request: Request) throws -> ResponseRepresentable {
        let lesson = try request.parameters.next(Lesson.self)
        return try lesson.teachers().makeJSON()
    }
}

// Notice the difference between Item and Muliple
extension LessonController: ResourceRepresentable {
    func makeResource() -> Resource<Lesson> {
        return Resource(
            index: getAll,
            store: create,
            show: getOne,
            update: update,
            destroy: delete
        )
    }
}

// Convenience of retrieving Lesson object
extension Request {
    fileprivate func lesson() throws -> Lesson {
        guard let json = json else { throw Abort.badRequest }
        
        return try Lesson(json: json)
    }
}

// Convenience of retrieving Teacher siblings
extension Lesson {
    func teachers() throws -> [Teacher] {
        let teachers: Siblings<Lesson, Teacher, Pivot<Teacher, Lesson>> = siblings()
        return try teachers.all()
    }
}
