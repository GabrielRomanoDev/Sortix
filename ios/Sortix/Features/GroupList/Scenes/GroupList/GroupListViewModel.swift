/// Drives the group list, the first screen of the app (flow 4.1).
///
/// It signs in anonymously before anything else. Memberships are not loaded yet: until
/// `MembershipServiceProtocol` exists, a successful sign-in always settles on `.empty`.
@MainActor
final class GroupListViewModel {
    enum Navigation {
        case createGroup
        case openWebPage(WebPage)
    }

    var onStateChange: ((GroupListState) -> Void)?
    var onNavigation: ((Navigation) -> Void)?

    private(set) var state: GroupListState = .loading
    /// The running sign-in. Tests await it to check the final state.
    private(set) var loadingTask: Task<Void, Never>?

    /// Shown in the "About" menu, such as "1.0".
    let appVersion: String

    private let authService: any AuthServiceProtocol
    private let crashReporter: any CrashReporterProtocol

    init(
        authService: any AuthServiceProtocol,
        crashReporter: any CrashReporterProtocol,
        appVersion: String
    ) {
        self.authService = authService
        self.crashReporter = crashReporter
        self.appVersion = appVersion
    }

    deinit {
        loadingTask?.cancel()
    }

    func viewDidLoad() {
        loadGroups()
    }

    func didTapRetry() {
        loadGroups()
    }

    func didTapCreateGroup() {
        onNavigation?(.createGroup)
    }

    func didTapPrivacyPolicy() {
        onNavigation?(.openWebPage(.privacy))
    }

    func didTapSupport() {
        onNavigation?(.openWebPage(.support))
    }

    // MARK: - Loading

    private func loadGroups() {
        loadingTask?.cancel()
        updateState(.loading)
        loadingTask = Task { [weak self] in
            await self?.signIn()
        }
    }

    private func signIn() async {
        do {
            _ = try await authService.ensureSignedIn()
            updateState(.empty)
        } catch {
            handleSignInError(ServiceError(error))
        }
    }

    private func handleSignInError(_ error: ServiceError) {
        // No internet is expected; anything else is reported (flow 4.1).
        if error != .network {
            crashReporter.recordNonFatal(error, context: [
                "operation": ServiceOperation.signIn.rawValue,
                "reason": error.reason.rawValue,
                "screen": "groupList"
            ])
        }
        updateState(.failed(error))
    }

    private func updateState(_ newState: GroupListState) {
        state = newState
        onStateChange?(newState)
    }
}
