//
//  StudentController.swift
//  ScheduleServer
//
//  Created by ShengHua Wu on 03/07/2017.
//
//

import PostgreSQLProvider

final class StudentController: ResourceRepresentable {
    private func getAll(request: Request) throws -> ResponseRepresentable {
        return try Student.all().makeJSON()
    }
    
    private func getOne(request: Request, student: Student) throws -> ResponseRepresentable {
        return student
    }
    
    private func create(request: Request) throws -> ResponseRepresentable {
        let student = try request.student()
        try student.save()
        return student
    }
    
    private func update(request: Request, student: Student) throws -> ResponseRepresentable {
        let newStudent = try request.student()
        student.name = newStudent.name
        try student.save()
        return student
    }
    
    private func delete(request: Request, student: Student) throws -> ResponseRepresentable {
        try student.delete()
        return student
    }
    
    func makeResource() -> Resource<Student> {
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
    fileprivate func student() throws -> Student {
        guard let json = json else { throw Abort.badRequest }
        
        return try Student(json: json)
    }
}
