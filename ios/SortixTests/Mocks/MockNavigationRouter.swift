import UIKit
@testable import Sortix

/// Records navigation calls so coordinator tests can check them without a window.
@MainActor
final class MockNavigationRouter: NavigationRouting {
    let rootViewController = UIViewController()

    private(set) var root: UIViewController?
    private(set) var pushedViewControllers: [UIViewController] = []
    private(set) var presentedViewControllers: [UIViewController] = []
    private var popHandlers: [ObjectIdentifier: () -> Void] = [:]

    func setRoot(_ viewController: UIViewController, animated: Bool) {
        root = viewController
        pushedViewControllers = []
    }

    func push(_ viewController: UIViewController, animated: Bool, onPop: (() -> Void)?) {
        pushedViewControllers.append(viewController)
        popHandlers[ObjectIdentifier(viewController)] = onPop
    }

    func popToRoot(animated: Bool) {
        pushedViewControllers = []
    }

    func present(_ viewController: UIViewController, animated: Bool) {
        presentedViewControllers.append(viewController)
    }

    func dismiss(animated: Bool, completion: (() -> Void)?) {
        presentedViewControllers.removeLast()
        completion?()
    }

    /// Simulates the person going back from a pushed screen.
    func simulateBack(from viewController: UIViewController) {
        pushedViewControllers.removeAll { $0 === viewController }
        popHandlers.removeValue(forKey: ObjectIdentifier(viewController))?()
    }
}
