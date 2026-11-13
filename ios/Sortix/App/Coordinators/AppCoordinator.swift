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
        let viewModel = GroupListViewModel()
        viewModel.onNavigation = { [weak self] navigation in
            self?.handle(navigation)
        }
        return GroupListViewController(viewModel: viewModel)
    }

    // MARK: - Navigation

    private func handle(_ navigation: GroupListViewModel.Navigation) {
        switch navigation {
        case .createGroup:
            startCreateGroupFlow()
        }
    }

    private func startCreateGroupFlow() {
        // TODO(create-group): start CreateGroupCoordinator modally once stage 13 adds the flow.
    }
}
