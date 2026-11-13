import Testing
import UIKit
@testable import Sortix

@MainActor
struct NavigationRouterTests {
    @Test func pushAddsToTheStack() {
        let router = NavigationRouter(navigationController: UINavigationController())
        let root = UIViewController()
        let pushed = UIViewController()

        router.setRoot(root, animated: false)
        router.push(pushed, animated: false, onPop: nil)

        #expect(router.navigationController.viewControllers == [root, pushed])
    }

    @Test func setRootReplacesTheStack() {
        let router = NavigationRouter(navigationController: UINavigationController())
        let newRoot = UIViewController()

        router.setRoot(UIViewController(), animated: false)
        router.push(UIViewController(), animated: false, onPop: nil)
        router.setRoot(newRoot, animated: false)

        #expect(router.navigationController.viewControllers == [newRoot])
    }

    @Test func routerIsTheNavigationDelegate() {
        let navigationController = UINavigationController()
        let router = NavigationRouter(navigationController: navigationController)

        #expect(navigationController.delegate === router)
    }
}
