## Server Side Swift with Vapor 2
Before Swift was open source in 2015, I had tried to write a simple RESTful API server with Node.js.
However, I did not have enough time digging deeper because I have not been familiar with Javascript syntax and backend development.
Nowadays, there are several different server side Swift frameworks, such as [Vapor](https://github.com/vapor/vapor), [Perfect](https://github.com/PerfectlySoft/Perfect), and [Kitura](https://github.com/IBM-Swift/Kitura).
As an iOS developer, it is a good chance to broaden my horizon in backend development.

### Why Vapor
According to its GitHub page, Vapor is the most used web framework for Swift.
It provides a beautifully expressive and easy to use foundation for your next website, API, or cloud project.
More importantly, there are series free [tutorials on raywenderlich.com website](https://videos.raywenderlich.com/screencasts/509-server-side-swift-with-vapor-getting-started).
These tutorials give me a basic concept of how to build up an API server with Vapor, even though they are made in the previous version.
Thank you [Ray](https://twitter.com/rwenderlich)!

### Introduction
In this article, I will demonstrate a simple API server which manipulates three models: Lesson, Teacher, and Student.
Basically, we need the following endpoints:

1. /{models}: Fetch all model objects via a GET request or create a new model object via a POST request with a JSON body. (Just replace {models} with lessons, teachers, and students.)
2. /{models}/id: Fetch a specific model object via a GET request, delete one model object via a DELETE request, or update an existing model object via a PATCH request with a JSON body.
3. /teachers/teacher_id/teaches/lesson_id: Set a sibling (many to many) relationship between Teacher and Lesson.
4. /teachers/teacher_id/lessons: Fetch all Lesson objects corresponding to a specific Teacher object.
5. /lessons/lesson_id/teachers: Fetch all Teacher objects corresponding to a specific Lesson object.
6. /students/student_id/enrolls/lesson_id: Set a sibling relationship between Student and Lesson.
7. /students/student_id/lessons: Fetch all Lesson objects corresponding to a specific Student object.
8. /lessons/lesson_id/students: Fetch all Student objects corresponding to a specific Lesson object.
