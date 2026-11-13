import UIKit

/// Navigation operations coordinators use, so tests can swap in `MockNavigationRouter`.
@MainActor
protocol NavigationRouting: AnyObject {
    /// The controller to install as the window root or to present modally.
    var rootViewController: UIViewController { get }

    func setRoot(_ viewController: UIViewController, animated: Bool)
    /// `onPop` runs when the screen leaves the stack through the Back button or the swipe gesture.
    func push(_ viewController: UIViewController, animated: Bool, onPop: (() -> Void)?)
    func popToRoot(animated: Bool)
    func present(_ viewController: UIViewController, animated: Bool)
    func dismiss(animated: Bool, completion: (() -> Void)?)
}
