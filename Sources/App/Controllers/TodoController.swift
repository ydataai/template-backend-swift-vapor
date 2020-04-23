import Vapor

// ⚠️ Ideally this will be a struct
final class TodoController: RouteCollection {

    // ⚠️ This is for test purposes, we shouldn't write data in memory like this,
    // when running in production, there are a lot of threads accessing this data.
    private var todos = [
        Todo(title: "Clean"),
        Todo(title: "Add middlewares"),
        Todo(title: "Add dotenv files for environments"),
        Todo(title: "Deploy")
    ]

    // - MARK: Routes Declaration
    func boot(routes: RoutesBuilder) throws {
        routes.get("todos", use: index)
        routes.post("todos", use: create)
        routes.delete("todos", ":todoID", use: delete)
    }

    // - MARK: Routes Implementation

    func index(req: Request) throws -> EventLoopFuture<[Todo]> {
        // If the function only has one instruction, you don't need the return
        req.eventLoop.future(todos)
    }

    func create(req: Request) throws -> EventLoopFuture<Todo> {
        let todo = try req.content.decode(Todo.self)

        return req.eventLoop.submit {
            self.todos += [todo]

            return todo
        }
    }

    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let todoID = req.parameters.get("todoID", as: UUID.self) else {
            throw Abort(.badRequest)
        }

        return req.eventLoop.submit {
            let todos = self.todos.filter { $0.id == todoID }
            self.todos = todos
            return .ok
        }
    }
}
