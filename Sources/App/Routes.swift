import Vapor
import PostgreSQLProvider

extension Droplet {
    func setupRoutes() throws {
        get("hello") { req in
            var json = JSON()
            try json.set("hello", "world")
            return json
        }
        
        get("version") { [weak self] req in
            if let strongSelf = self {
                let db = try strongSelf.postgresql()
                let version = try db.raw("SELECT version()")
                return JSON(node: version)
            } else {
                return "No DB connection"
            }
        }
    }
}
