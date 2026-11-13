import Testing
@testable import Sortix

@MainActor
struct GroupListSceneTests {
    @Test func sceneIsReleased() {
        expectDeallocation {
            let viewModel = GroupListViewModel()
            let viewController = GroupListViewController(viewModel: viewModel)
            viewController.loadViewIfNeeded()
            return [viewController, viewModel]
        }
    }

    @Test func tappingCreateGroupEmitsNavigation() {
        let viewModel = GroupListViewModel()
        var events: [GroupListViewModel.Navigation] = []
        viewModel.onNavigation = { events.append($0) }

        viewModel.didTapCreateGroup()

        #expect(events.count == 1)
    }
}
