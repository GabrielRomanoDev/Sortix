import Testing
@testable import Sortix
import UIKit

@MainActor
struct GroupListSceneTests {
    private func makeViewModel(
        authService: MockAuthService = MockAuthService(),
        crashReporter: MockCrashReporter = MockCrashReporter()
    ) -> GroupListViewModel {
        GroupListViewModel(authService: authService, crashReporter: crashReporter, appVersion: "1.0")
    }

    @Test func sceneIsReleased() {
        expectDeallocation {
            let viewModel = makeViewModel()
            let viewController = GroupListViewController(viewModel: viewModel)
            viewController.loadViewIfNeeded()
            return [viewController, viewModel]
        }
    }

    @Test func startsLoadingAndShowsEmptyAfterSignIn() async {
        let viewModel = makeViewModel()
        var states: [GroupListState] = []
        viewModel.onStateChange = { states.append($0) }

        viewModel.viewDidLoad()
        await viewModel.loadingTask?.value

        #expect(states == [.loading, .empty])
    }

    @Test func noInternetShowsTheErrorWithoutReporting() async {
        let crashReporter = MockCrashReporter()
        let viewModel = makeViewModel(
            authService: MockAuthService(result: .failure(.network)),
            crashReporter: crashReporter
        )

        viewModel.viewDidLoad()
        await viewModel.loadingTask?.value

        #expect(viewModel.state == .failed(.network))
        #expect(crashReporter.records.isEmpty)
    }

    @Test func unexpectedErrorIsReportedWithCodesOnly() async {
        let crashReporter = MockCrashReporter()
        let viewModel = makeViewModel(
            authService: MockAuthService(result: .failure(.unauthenticated)),
            crashReporter: crashReporter
        )

        viewModel.viewDidLoad()
        await viewModel.loadingTask?.value

        #expect(viewModel.state == .failed(.unauthenticated))
        #expect(crashReporter.records.first?.context == [
            "operation": "signIn",
            "reason": "UNAUTHENTICATED",
            "screen": "groupList"
        ])
    }

    @Test func retryLoadsAgain() async {
        let viewModel = makeViewModel()
        var states: [GroupListState] = []
        viewModel.onStateChange = { states.append($0) }

        viewModel.didTapRetry()
        await viewModel.loadingTask?.value

        #expect(states == [.loading, .empty])
    }

    @Test func tappingCreateGroupEmitsNavigation() {
        let viewModel = makeViewModel()
        var events: [GroupListViewModel.Navigation] = []
        viewModel.onNavigation = { events.append($0) }

        viewModel.didTapCreateGroup()

        #expect(events.count == 1)
    }

    @Test func aboutMenuOpensTheWebsitePages() {
        let viewModel = makeViewModel()
        var pages: [WebPage] = []
        viewModel.onNavigation = { navigation in
            if case .openWebPage(let page) = navigation {
                pages.append(page)
            }
        }

        viewModel.didTapPrivacyPolicy()
        viewModel.didTapSupport()

        #expect(pages == [.privacy, .support])
    }
}
