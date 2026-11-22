import Foundation

/// Stores the local preferences in `UserDefaults`.
///
/// Only the organizer's own name and group IDs are kept here, never tokens (BR-55).
@MainActor
final class UserDefaultsSettingsStore: LocalSettingsStoreProtocol {
    private enum Key {
        static let lastOrganizerName = "lastOrganizerName"
        static let savedRecoveryLinkGroupIDs = "savedRecoveryLinkGroupIDs"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults) {
        self.defaults = defaults
    }

    var lastOrganizerName: String? {
        get { defaults.string(forKey: Key.lastOrganizerName) }
        set { defaults.set(newValue, forKey: Key.lastOrganizerName) }
    }

    func isRecoveryLinkSaved(for groupID: GroupID) -> Bool {
        savedRecoveryLinkGroupIDs().contains(groupID.rawValue)
    }

    func markRecoveryLinkSaved(for groupID: GroupID) {
        var groupIDs = savedRecoveryLinkGroupIDs()
        guard !groupIDs.contains(groupID.rawValue) else { return }
        groupIDs.append(groupID.rawValue)
        defaults.set(groupIDs, forKey: Key.savedRecoveryLinkGroupIDs)
    }

    private func savedRecoveryLinkGroupIDs() -> [String] {
        defaults.stringArray(forKey: Key.savedRecoveryLinkGroupIDs) ?? []
    }
}
