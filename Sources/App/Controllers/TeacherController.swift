//
//  TeacherController.swift
//  ScheduleServer
//
//  Created by ShengHua Wu on 03/07/2017.
//
//

import PostgreSQLProvider

final class TeacherController: ResourceRepresentable {
    private func getAll(request: Request) throws -> ResponseRepresentable {
        return try Teacher.all().makeJSON()
    }
    
    private func getOne(request: Request, teacher: Teacher) throws -> ResponseRepresentable {
        return teacher
    }
    
    private func create(request: Request) throws -> ResponseRepresentable {
        let teacher = try request.teacher()
        try teacher.save()
        return teacher
    }
    
    private func update(request: Request, teacher: Teacher) throws -> ResponseRepresentable {
        let newTeacher = try request.teacher()
        teacher.name = newTeacher.name
        try teacher.save()
        return teacher
    }
    
    private func delete(request: Request, teacher: Teacher) throws -> ResponseRepresentable {
        try teacher.delete()
        return teacher
    }
    
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
