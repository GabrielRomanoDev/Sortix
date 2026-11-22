import Testing
@testable import Sortix
import UIKit

@MainActor
struct CreateGroupCoordinatorTests {
    private func makeCoordinator(
        router: MockNavigationRouter,
        presentingRouter: MockNavigationRouter
    ) -> CreateGroupCoordinator {
        CreateGroupCoordinator(router: router, presentingRouter: presentingRouter, dependencies: .mock())
    }

    @Test func startPresentsTheRulesStepModally() {
        let router = MockNavigationRouter()
        let presentingRouter = MockNavigationRouter()
        let coordinator = makeCoordinator(router: router, presentingRouter: presentingRouter)

        coordinator.start()

        #expect(router.root is GroupRulesViewController)
        #expect(presentingRouter.presentedViewControllers.first === router.rootViewController)
    }

    @Test func swipingDownWithoutDataFinishes() {
        let router = MockNavigationRouter()
        let presentingRouter = MockNavigationRouter()
        let coordinator = makeCoordinator(router: router, presentingRouter: presentingRouter)
        var results: [CreateGroupCoordinator.Result] = []
        coordinator.onFinish = { results.append($0) }
        coordinator.start()
        let presentation = UIPresentationController(
            presentedViewController: router.rootViewController,
            presenting: nil
        )

        #expect(coordinator.presentationControllerShouldDismiss(presentation))
        coordinator.presentationControllerDidDismiss(presentation)

        #expect(results == [.cancelled])
    }

    @Test func coordinatorIsReleasedWithItsScenes() {
        expectDeallocation {
            let router = MockNavigationRouter()
            let presentingRouter = MockNavigationRouter()
            let coordinator = makeCoordinator(router: router, presentingRouter: presentingRouter)
            coordinator.start()
            return [coordinator, router, presentingRouter]
        }
    }
}
