import Vapor

extension Droplet {
    func setupRoutes() throws {
        let lessonController = LessonController()
        resource("lessons", lessonController)
    }
}
