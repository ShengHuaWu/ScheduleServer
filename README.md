## Server Side Swift with Vapor 2 (Part 1)
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
In this article, I will demonstrate a simple RESTful API server which manipulates three models: Lesson, Teacher, and Student.
Basically, we need the following endpoints:

1. /{models}: Fetch all model objects via a GET request or create a new model object via a POST request with a JSON body. (Just replace {models} with lessons, teachers, and students.)
2. /{models}/id: Fetch a specific model object via a GET request, delete one model object via a DELETE request, or update an existing model object via a PATCH request with a JSON body.

### Configuration
Before we dive into coding, there are several necessary configurations.
First of all, follow [the instructions on Vapor's website](https://docs.vapor.codes/2.0/getting-started/install-on-macos/) to install Vapor correctly, and then use `vapor your_project_name --template=api` to create a new project.
Secondly, I choose to use PostgreSQL as my database server in this project, so it is necessary to install PostgreSQL on my Macbook and add the [PostgreSQL provider for Vapor](https://github.com/vapor-community/postgresql-provider) into my project dependencies.
After starting PostgreSQL server, open and modify the `Package.swift` file as following.
```
let package = Package(
    // ...
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 2),
        .Package(url: "https://github.com/vapor-community/postgresql-provider.git", majorVersion: 2)
    ],
    // ...
)
```
Then, create a new file called `postgresql.json` under the directory `Config/secrets` and add the following code snippet into the `postgresql.json` file.
```
{
    "hostname": your_host_address,
    "user": your_username,
    "password": your_password,
    "database": your_database_name,
    "port": 5432
}
```
The final step is to add the PostgreSQL provider within the `Config+Setup.swift` file.
```
import PostgreSQLProvider

extension Config {
    // ...
    private func setupProviders() throws {
        try addProvider(FluentProvider.Provider.self)
        try addProvider(PostgreSQLProvider.Provider.self)
    }
    // ...
}
```
After finishing all configurations, use `vapor build` and `vapor xcode` to fetch the necessary dependencies and generate a new Xcode project.

### Implementation
Let's handle our model class at first.
Open the Xcode project that we generate at the previous step, and add `Lesson.swift`, `Teacher.swift`, and `Student.swift` files into the `Models` group.
When adding a new file to our project, make sure the choose the target as App.

![ChooseTarget](https://github.com/ShengHuaWu/ScheduleServer/blob/master/Resources/ChooseTarget.png)

Moreover, follow [Vapor's document](https://docs.vapor.codes/2.0/fluent/getting-started/) to define our model properly.
Because their implementations are quite similar, I just show `Lesson.swift` as following.
```
import PostgreSQLProvider

final class Lesson: Model {
    let storage = Storage() // This is for Storable protocol

    var title: String

    // Use these keys instead of magic strings
    static let idKey = "id"
    static let titleKey = "title"

    init(title: String) {
        self.title = title
    }

    init(row: Row) throws {
        self.title = try row.get(Lesson.titleKey)
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Lesson.titleKey, title)
        return row
    }
}

// For database prepare and revert
extension Lesson: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { (user) in
            user.id()
            user.string(Lesson.titleKey)
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// Convenience of generate model from JSON
extension Lesson: JSONConvertible {
    convenience init(json: JSON) throws {
        self.init(title: try json.get(Lesson.titleKey))
    }

    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Lesson.idKey, id?.string)
        try json.set(Lesson.titleKey, title)
        return json
    }
}

// Convenience of returning response
extension Lesson: ResponseRepresentable {}
```
After creating our models, switch to `Config+Setup.swift` file and add the preparations.
```
private func setupPreparations() throws {
    preparations.append(Lesson.self)
    preparations.append(Teacher.self)
    preparations.append(Student.self)
}
```
Next, add the controllers corresponding to our models in the `Controllers` group as well.
Inside each controller, we can take the advantages of Vapor's `ResourceRepresentable` protocol to deal with model's CRUD.
Again, for the simplicity, I just display the implementation of `LessonController.swift` as following.
```
import PostgreSQLProvider

final class LessonController {
    fileprivate func getAll(request: Request) throws -> ResponseRepresentable {
        return try Lesson.all().makeJSON()
    }

    fileprivate func getOne(request: Request, lesson: Lesson) throws -> ResponseRepresentable {
        return lesson
    }

    fileprivate func create(request: Request) throws -> ResponseRepresentable {
        let lesson = try request.lesson()
        try lesson.save()
        return lesson
    }

    fileprivate func update(request: Request, lesson: Lesson) throws -> ResponseRepresentable {
        let newLesson = try request.lesson()
        lesson.title = newLesson.title
        try lesson.save()
        return lesson
    }

    fileprivate func delete(request: Request, lesson: Lesson) throws -> ResponseRepresentable {
        try lesson.delete()
        return lesson
    }
}

// Notice the difference between Item and Muliple
extension LessonController: ResourceRepresentable {
    func makeResource() -> Resource<Lesson> {
        return Resource(
            index: getAll,
            store: create,
            show: getOne,
            update: update,
            destroy: delete
        )
    }
}

// Convenience of retrieving Lesson object
extension Request {
    fileprivate func lesson() throws -> Lesson {
        guard let json = json else { throw Abort.badRequest }

        return try Lesson(json: json)
    }
}
```
Finally, hook up our controllers and the `Droplet` object via adding the following line into `Router.swift` file.
```
func setupRoutes() throws {
    let lessonController = LessonController()
    resource("lessons", lessonController)

    let teacherController = TeacherController()
    resource("teachers", teacherController)

    let studentController = StudentController()
    resource("students", studentController)
}
```

### Where To Go From Here
At this point, we achieve a simple RESTful API server, and we can test model CRUD with [Postman](https://www.getpostman.com).
In the part 2 of this series, I will demonstrate how to implement a sibling (many to many) relationship between two models.
