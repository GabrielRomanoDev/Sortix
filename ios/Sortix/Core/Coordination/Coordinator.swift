/// A flow controller that builds scenes, injects their dependencies and navigates between them.
@MainActor
protocol Coordinator: AnyObject {
    var childCoordinators: [any Coordinator] { get set }
    func start()
}

extension Coordinator {
    func addChild(_ child: any Coordinator) {
        childCoordinators.append(child)
    }

    func removeChild(_ child: any Coordinator) {
        childCoordinators.removeAll { $0 === child }
    }
}
