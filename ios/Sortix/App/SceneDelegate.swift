import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    /// Kept alive for the whole scene; it owns every child coordinator.
    private var appCoordinator: AppCoordinator?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let navigationController = UINavigationController()
        navigationController.navigationBar.prefersLargeTitles = true
        let router = NavigationRouter(navigationController: navigationController)
        let coordinator = AppCoordinator(router: router, dependencies: .live())

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = router.rootViewController
        coordinator.start()
        window.makeKeyAndVisible()

        self.window = window
        appCoordinator = coordinator
    }
}
