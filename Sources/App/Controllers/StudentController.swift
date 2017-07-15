//
//  StudentController.swift
//  ScheduleServer
//
//  Created by ShengHua Wu on 03/07/2017.
//
//

import PostgreSQLProvider

final class StudentController {
    fileprivate func getAll(request: Request) throws -> ResponseRepresentable {
        return try Student.all().makeJSON()
    }

    fileprivate func getOne(request: Request, student: Student) throws -> ResponseRepresentable {
        return student
    }

    fileprivate func create(request: Request) throws -> ResponseRepresentable {
        let student = try request.student()
        try student.save()
        return student
    }

    fileprivate func update(request: Request, student: Student) throws -> ResponseRepresentable {
        let newStudent = try request.student()
        student.name = newStudent.name
        try student.save()
        return student
    }

    fileprivate func delete(request: Request, student: Student) throws -> ResponseRepresentable {
        try student.delete()
        return student
    }

    func addRouters(_ drop: Droplet) {
        let studentsGroup = drop.grouped("students")
        studentsGroup.post(Student.parameter, "enrolls", Lesson.parameter, handler: enrolls)
        studentsGroup.get(Student.parameter, "lessons", handler: lessons)
    }

    private func enrolls(request: Request) throws -> ResponseRepresentable {
        let student = try request.parameters.next(Student.self)
        let lesson = try request.parameters.next(Lesson.self)
        let pivot = try Pivot<Student, Lesson>(student, lesson)
        try pivot.save()

        return student
    }

    private func lessons(request: Request) throws -> ResponseRepresentable {
        let student = try request.parameters.next(Student.self)
        return try student.lessons().makeJSON()
    }
}

extension StudentController: ResourceRepresentable {
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

extension Student {
    func lessons() throws -> [Lesson] {
        let lessons: Siblings<Student, Lesson, Pivot<Student, Lesson>> = siblings()
        return try lessons.all()
    }
}
