## Server Side Swift with Vapor 2 (Part 1)
Before Swift was open source in 2015, I had tried to write a simple RESTful API server with Node.js.
However, I did not have enough time digging deeper because I have not been familiar with Javascript syntax and back-end development.
Nowadays, there are several different server side Swift frameworks, such as [Vapor](https://github.com/vapor/vapor), [Perfect](https://github.com/PerfectlySoft/Perfect), and [Kitura](https://github.com/IBM-Swift/Kitura).
As an iOS developer, it is a good chance to broaden my horizon in back-end development.

### Why Vapor
According to its GitHub page, Vapor is the most used web framework for Swift.
It provides a beautifully expressive and easy to use foundation for your next website, API, or cloud project.
More importantly, there are series free [tutorials on raywenderlich.com website](https://videos.raywenderlich.com/screencasts/509-server-side-swift-with-vapor-getting-started).
These tutorials give me a basic concept of how to build up an API server with Vapor, even though they are made in the previous version.
Thank you [Ray](https://twitter.com/rwenderlich)!

### Introduction
In this article, I will demonstrate a simple RESTful API server which manipulates three models: `Lesson`, `Teacher`, and `Student`.
Basically, we need the following endpoints:

1. `/{models}`: Fetch all model objects via a GET request or create a new model object via a POST request with a JSON body. (Just replace {models} with lessons, teachers, and students.)
2. `/{models}/id`: Fetch a specific model object via a GET request, delete one model object via a DELETE request, or update an existing model object via a PATCH request with a JSON body.

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
In [the part 2 of this series](https://medium.com/@shenghuawu/server-side-swift-with-vapor-2-part-2-844146ef1994), I will demonstrate how to implement a sibling (many to many) relationship between two models.

## Server Side Swift with Vapor 2 (Part 2)
In [the previous part of this series](https://medium.com/@shenghuawu/server-side-swift-with-vapor-2-part-1-1b050c19249b), we have created a RESTful API server which manipulates three models --- `Lesson`, `Teacher`, and `Student`.
In this article, I am going to build up a sibling relationship between `Teacher` and `Lesson`, and it is possible to follow the same pattern to achieve the relationship between `Student` and `Lesson`.

### Introduction
Basically, we need to define the following three endpoints:

1. `/teachers/teacher_id/teaches/lesson_id`: Set a sibling relationship between `Teacher` and `Lesson` via a POST request.
2. `/teachers/teacher_id/lessons`: Fetch all `Lesson` objects corresponding to a specific `Teacher` object.
3. `/lessons/lesson_id/teachers`: Fetch all `Teacher` objects corresponding to a specific `Lesson` object.

### Implementation
First of all, in order to describe a sibling relationship, it is necessary to store the pair of models' identifiers into a new table called `Pivot`.
Therefore, let's move to the `Config+Setup.swift` file and add the following line into the `setupPreparations` method.
```
private func setupPreparations() throws {
    // ...
    preparations.append(Pivot<Teacher, Lesson>.self)
}
```
Secondly, we also need to define a new endpoint, in order to save the identifier pair into our `Pivot` table via a POST request.
Thus, switch to `TeahcerController.swift` file and add the following two new methods.
```
func addRoutes(_ drop: Droplet) {
    let teachersGroup = drop.grouped("teachers")
    teachersGroup.post(Teacher.parameter, "teaches", Lesson.parameter, handler: teaches)
  }

private func teaches(request: Request) throws -> ResponseRepresentable {
    let teacher = try request.parameters.next(Teacher.self)
    let lesson = try request.parameters.next(Lesson.self)
    let pivot = try Pivot<Teacher, Lesson>(teacher, lesson)
    try pivot.save()

    return teacher
}
```
The reason why we have to create the `addRoutes` method is this endpoint doesn't belong to the RESTful API design diagram.
In other words, we need this method to connect with the `Droplet` object.
So, open the `Routes.swift` file and modify the `setupRoutes` method.
```
func setupRoutes() throws {
    // ...
    let teacherController = TeacherController()
    resource("teachers", teacherController)
    teacherController.addRoutes(self)

    // ...
}
```
At this point, we are able to generate a sibling relationship between `Teacher` and `Lesson`.
Let's continue implementing how to retrieve the relevant model objects.
In `TeacherController.swift` file, add another new method and a new endpoint.
In addition, create an extension of `Teacher` to get the sibling of `Lesson` easily.
```
final class TeacherController {
  // ...

  func addRoutes(_ drop: Droplet) {
      let teachersGroup = drop.grouped("teachers")
      // ...
      teachersGroup.get(Teacher.parameter, "lessons", handler: lessons)
  }

  private func lessons(request: Request) throws -> ResponseRepresentable {
      let teacher = try request.parameters.next(Teacher.self)
      return try teacher.lessons().makeJSON()
  }
}

// ...

extension Teacher {
    func lessons() throws -> [Lesson] {
        let lessons: Siblings<Teacher, Lesson, Pivot<Teacher, Lesson>> = siblings()
        return try lessons.all()
    }
}
```
Next, we add the following methods and an extension of `Lesson` within `LessonController.swift`, in order to fetch the corresponding `Teacher` sibling.
```
final class LessonController {
    // ...

    func addRoutes(_ drop: Droplet) {
        let lessonsGroup = drop.grouped("lessons")
        lessonsGroup.get(Lesson.parameter, "teachers", handler: teachers)
    }

    private func teachers(request: Request) throws -> ResponseRepresentable {
        let lesson = try request.parameters.next(Lesson.self)
        return try lesson.teachers().makeJSON()
    }
}

// ...

extension Lesson {
    func teachers() throws -> [Teacher] {
        let teachers: Siblings<Lesson, Teacher, Pivot<Teacher, Lesson>> = siblings()
        return try teachers.all()
    }
}
```
Finally, remember to hook up the new endpoint with the `Droplet` object in `Routes.swift` file.
```
func setupRoutes() throws {
    let lessonController = LessonController()
    resource("lessons", lessonController)
    lessonController.addRoutes(self)

    // ...
}
```

### Conclusion
The entire sample code is [here](https://github.com/ShengHuaWu/ScheduleServer).

Again, we can test our new endpoints with [Postman](https://www.getpostman.com).
However, let's talk about the pros and cons of Vapor.
On one hand, the merits include [well-defined documentations](https://docs.vapor.codes/2.0/), useful built-in functions, and [a migration tool](https://github.com/vapor/migrator).
On the other hand, the downsides are fewer search results for Vapor 2 than 1, and Swift keeps evolving.
Still, I personally think Vapor is a good opportunity to learn back-end development for a iOS developer.
I'm totally open to discussion and feedback, so please share your thoughts.
