import Vapor
import PostgreSQLProvider

extension Droplet {
    func setupRoutes() throws {
        setupLessonRoutes()
    }
}

extension Droplet {
    func setupLessonRoutes() {
        group("lessons") { (lessons) in
            lessons.get("") { (req) in
                return try Lesson.all().makeJSON()
            }
            
            lessons.get(Int.parameter) { (req) in
                let id = try req.parameters.next(Int.self)
                guard let lesson = try Lesson.makeQuery().filter("id", id).first() else {
                    throw Abort.notFound
                }
                
                return lesson
            }
            
            lessons.post("") { (req) in
                guard let title = req.data["title"]?.string else {
                    throw Abort.badRequest
                }
                
                let lesson = Lesson(title: title)
                try lesson.save()
                return lesson
            }
            
            lessons.put(Int.parameter) { (req) in
                let id = try req.parameters.next(Int.self)
                guard let lesson = try Lesson.makeQuery().filter("id", id).first() else {
                    throw Abort.notFound
                }
                
                guard let title = req.data["title"]?.string else {
                    throw Abort.badRequest
                }
                
                lesson.title = title
                try lesson.save()
                return lesson
            }
            
            lessons.delete(Int.parameter) { (req) in
                let id = try req.parameters.next(Int.self)
                guard let lesson = try Lesson.makeQuery().filter("id", id).first() else {
                    throw Abort.notFound
                }
                
                try lesson.delete()
                return lesson
            }
        }
    }
}
