import UIKit

/// `NavigationRouting` on top of a `UINavigationController`.
///
/// The router is the navigation controller's delegate, so it can tell when a screen left the stack
/// through the Back button or the swipe gesture and call that screen's `onPop`. Coordinators use
/// the `onPop` of their first screen to tell their parent they finished.
@MainActor
final class NavigationRouter: NSObject, NavigationRouting {
    let navigationController: UINavigationController
    private var popHandlers: [ObjectIdentifier: () -> Void] = [:]

    var rootViewController: UIViewController { navigationController }

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
        navigationController.delegate = self
    }

    func setRoot(_ viewController: UIViewController, animated: Bool) {
        navigationController.setViewControllers([viewController], animated: animated)
    }

    func push(_ viewController: UIViewController, animated: Bool, onPop: (() -> Void)?) {
        popHandlers[ObjectIdentifier(viewController)] = onPop
        navigationController.pushViewController(viewController, animated: animated)
    }

    func popToRoot(animated: Bool) {
        navigationController.popToRootViewController(animated: animated)
    }

    func present(_ viewController: UIViewController, animated: Bool) {
        navigationController.present(viewController, animated: animated)
    }

    func dismiss(animated: Bool, completion: (() -> Void)?) {
        navigationController.dismiss(animated: animated, completion: completion)
    }
}

extension NavigationRouter: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        // Every screen with a handler that is no longer in the stack was popped.
        let screensInStack = Set(navigationController.viewControllers.map(ObjectIdentifier.init))
        for (screen, onPop) in popHandlers where !screensInStack.contains(screen) {
            popHandlers[screen] = nil
            onPop()
        }
    }
}
