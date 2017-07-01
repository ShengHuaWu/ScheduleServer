import Vapor

extension Droplet {
    func setupRoutes() throws {
        let lessonController = LessonController()
        lessonController.addRoutes(droplet: self)
    }
}
