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
        // TODO(create-group): start CreateGroupCoordinator modally once stage 13 adds the flow.
    }

    private func presentSafari(for page: WebPage) {
        let safari = SFSafariViewController(url: page.url)
        safari.preferredControlTintColor = ColorToken.accent
        router.present(safari, animated: true)
    }
}
