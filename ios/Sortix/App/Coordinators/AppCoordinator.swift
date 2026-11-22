import SafariServices
import UIKit

/// Root coordinator. Lives as long as the scene, owns the main navigation and starts the creation
/// and group flows as children.
@MainActor
final class AppCoordinator: Coordinator {
    var childCoordinators: [any Coordinator] = []

    private let router: any NavigationRouting
    private let dependencies: AppDependencies

    init(router: any NavigationRouting, dependencies: AppDependencies) {
        self.router = router
        self.dependencies = dependencies
    }

    func start() {
        router.setRoot(makeGroupListScene(), animated: false)
    }

    // MARK: - Scenes

    private func makeGroupListScene() -> UIViewController {
        let viewModel = GroupListViewModel(
            authService: dependencies.authService,
            crashReporter: dependencies.crashReporter,
            appVersion: appVersion()
        )
        viewModel.onNavigation = { [weak self] navigation in
            self?.handle(navigation)
        }
        return GroupListViewController(viewModel: viewModel)
    }

    private func appVersion() -> String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    }

    // MARK: - Navigation

    private func handle(_ navigation: GroupListViewModel.Navigation) {
        switch navigation {
        case .createGroup:
            startCreateGroupFlow()
        case .openWebPage(let page):
            presentSafari(for: page)
        }
    }

    private func startCreateGroupFlow() {
        let coordinator = CreateGroupCoordinator(
            router: NavigationRouter(navigationController: UINavigationController()),
            presentingRouter: router,
            dependencies: dependencies
        )
        // TODO(create-group-draw-review): on `.created`, start the group flow (stage 16).
        coordinator.onFinish = { [weak self, weak coordinator] _ in
            guard let self, let coordinator else { return }
            removeChild(coordinator)
        }
        addChild(coordinator)
        coordinator.start()
    }

    private func presentSafari(for page: WebPage) {
        let safari = SFSafariViewController(url: page.url)
        safari.preferredControlTintColor = ColorToken.accent
        router.present(safari, animated: true)
    }
}
