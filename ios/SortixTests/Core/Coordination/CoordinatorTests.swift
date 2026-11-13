import Testing
@testable import Sortix

@MainActor
struct CoordinatorTests {
    private final class TestCoordinator: Coordinator {
        var childCoordinators: [any Coordinator] = []
        func start() {}
    }

    @Test func addAndRemoveChild() {
        let parent = TestCoordinator()
        let first = TestCoordinator()
        let second = TestCoordinator()

        parent.addChild(first)
        parent.addChild(second)
        parent.removeChild(first)

        #expect(parent.childCoordinators.count == 1)
        #expect(parent.childCoordinators.first === second)
    }
}
