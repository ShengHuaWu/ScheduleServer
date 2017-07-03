import Vapor

extension Droplet {
    func setupRoutes() throws {
        let lessonController = LessonController()
        resource("lessons", lessonController)
        
        let teacherController = TeacherController()
        resource("teachers", teacherController)
        
        let studentController = StudentController()
        resource("students", studentController)
    }
}
