import Vapor
import PostgreSQLProvider

extension Droplet {
    func setupRoutes() throws {
        get("version") { [weak self] (req) in
            if let strongSelf = self {
                let db = try strongSelf.postgresql()
                let version = try db.raw("SELECT version()")
                return JSON(node: version)
            } else {
                return "No DB connection"
            }
        }
        
        get("lessons") { (req) in
            return try JSON(node: Lesson.all().map { try $0.makeJSON() })
        }
        
        post("lessons") { (req) in
            guard let title = req.data["title"]?.string else {
                throw Abort.badRequest
            }
            
            let lesson = Lesson(title: title)
            try lesson.save()
            return try lesson.makeJSON()
        }
    }
}
