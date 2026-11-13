import Testing
@testable import Sortix

@MainActor
struct AppCoordinatorTests {
    @Test func startShowsGroupListAsRoot() {
        let router = MockNavigationRouter()
        let coordinator = AppCoordinator(router: router, dependencies: .mock())

        coordinator.start()

        #expect(router.root is GroupListViewController)
        #expect(router.pushedViewControllers.isEmpty)
    }

    @Test func coordinatorIsReleasedWithItsScenes() {
        expectDeallocation {
            let router = MockNavigationRouter()
            let coordinator = AppCoordinator(router: router, dependencies: .mock())
            coordinator.start()
            return [coordinator, router]
        }
    }
}
