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
    
    // TODO: Need refactoring
    func addRoutes(_ drop: Droplet) {
        drop.get("teachers", Int.parameter, "lesson", handler: userIndex)
    }
    
    private func userIndex(request: Request) throws -> ResponseRepresentable {
        guard let teacher = try Teacher.makeQuery().filter("id", request.parameters.next() as Int).first() else {
            throw Abort.badRequest
        }
        
        return try JSON(node: teacher.lesson())
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
    func lesson() throws -> Lesson? {
        return try parent(id: lessonId, type: Lesson.self).get()
    }
}
