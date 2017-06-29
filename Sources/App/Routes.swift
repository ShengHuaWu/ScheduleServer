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
        
        get("test") { (req) in
            let lesson = Lesson(title: "English")
            try lesson.save()
            return try JSON(node: Lesson.all().map { try $0.makeJSON() })
        }
    }
}
