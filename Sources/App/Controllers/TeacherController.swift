//
//  TeacherController.swift
//  ScheduleServer
//
//  Created by ShengHua Wu on 03/07/2017.
//
//

import PostgreSQLProvider

final class TeacherController {
    fileprivate func getAll(request: Request) throws -> ResponseRepresentable {
        return try Teacher.all().makeJSON()
    }
    
    fileprivate func getOne(request: Request, teacher: Teacher) throws -> ResponseRepresentable {
        return teacher
    }
    
    fileprivate func create(request: Request) throws -> ResponseRepresentable {
        let teacher = try request.teacher()
        try teacher.save()
        return teacher
    }
    
    fileprivate func update(request: Request, teacher: Teacher) throws -> ResponseRepresentable {
        let newTeacher = try request.teacher()
        teacher.name = newTeacher.name
        try teacher.save()
        return teacher
    }
    
    fileprivate func delete(request: Request, teacher: Teacher) throws -> ResponseRepresentable {
        try teacher.delete()
        return teacher
    }
    
    func addRoutes(_ drop: Droplet) {
        let teachersGroup = drop.grouped("teachers")
        teachersGroup.post(Teacher.parameter, "teaches", Lesson.parameter, handler: teaches)
        teachersGroup.get(Teacher.parameter, "lessons", handler: lessons)
    }
    
    private func teaches(request: Request) throws -> ResponseRepresentable {
        let teacher = try request.parameters.next(Teacher.self)
        let lesson = try request.parameters.next(Lesson.self)
        let pivot = try Pivot<Teacher, Lesson>(teacher, lesson)
        try pivot.save()
        
        return teacher
    }
    
    private func lessons(request: Request) throws -> ResponseRepresentable {
        let teacher = try request.parameters.next(Teacher.self)
        return try teacher.lessons().makeJSON()
    }
}

extension TeacherController: ResourceRepresentable {
    func makeResource() -> Resource<Teacher> {
        return Resource(
            index: getAll,
            store: create,
            show: getOne,
            update: update,
            destroy: delete
        )
    }
}

extension Request {
    fileprivate func teacher() throws -> Teacher {
        guard let json = json else { throw Abort.badRequest }
        
        return try Teacher(json: json)
    }
}

extension Teacher {
    func lessons() throws -> [Lesson] {
        let lessons: Siblings<Teacher, Lesson, Pivot<Teacher, Lesson>> = siblings()
        return try lessons.all()
    }
}
