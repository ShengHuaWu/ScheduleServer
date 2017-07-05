import Vapor

extension Droplet {
    func setupRoutes() throws {
        // Add routes with -resource method
        let lessonController = LessonController()
        resource("lessons", lessonController)
        
        let teacherController = TeacherController()
        resource("teachers", teacherController)
        
        let studentController = StudentController()
        resource("students", studentController)
    }
}
