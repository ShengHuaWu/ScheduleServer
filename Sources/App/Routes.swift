import Vapor

extension Droplet {
    func setupRoutes() throws {
        // Add routes with -resource method
        let lessonController = LessonController()
        resource("lessons", lessonController)
        lessonController.addRoutes(self)
        
        let teacherController = TeacherController()
        resource("teachers", teacherController)
        teacherController.addRoutes(self)
        
        let studentController = StudentController()
        resource("students", studentController)
    }
}
