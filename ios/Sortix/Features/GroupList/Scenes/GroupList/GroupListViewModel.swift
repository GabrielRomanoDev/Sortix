/// Drives the group list, the first screen of the app.
///
/// Memberships are not loaded yet: until `MembershipServiceProtocol` exists, the list always
/// settles on `.empty`, which is enough to exercise the view code setup end to end.
@MainActor
final class GroupListViewModel {
    enum Navigation {
        case createGroup
    }

    var onStateChange: ((GroupListState) -> Void)?
    var onNavigation: ((Navigation) -> Void)?

    private(set) var state: GroupListState = .loading

    func viewDidLoad() {
        updateState(.empty)
    }

    func didTapCreateGroup() {
        onNavigation?(.createGroup)
    }

    private func updateState(_ newState: GroupListState) {
        state = newState
        onStateChange?(newState)
    }
}
