@testable import Sortix

/// Keeps the preferences in memory, so tests never touch `UserDefaults`.
@MainActor
final class MockSettingsStore: LocalSettingsStoreProtocol {
    var lastOrganizerName: String?
    var hasSeenRestrictionsTip = false
    private(set) var savedRecoveryLinkGroupIDs: Set<GroupID> = []

    func isRecoveryLinkSaved(for groupID: GroupID) -> Bool {
        savedRecoveryLinkGroupIDs.contains(groupID)
    }

    func markRecoveryLinkSaved(for groupID: GroupID) {
        savedRecoveryLinkGroupIDs.insert(groupID)
    }
}
