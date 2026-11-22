import Foundation
import Testing
@testable import Sortix

@MainActor
struct UserDefaultsSettingsStoreTests {
    /// A separate suite per test, so tests never read or change the app's real preferences.
    private func makeStore() throws -> UserDefaultsSettingsStore {
        let suiteName = "UserDefaultsSettingsStoreTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
        return UserDefaultsSettingsStore(defaults: defaults)
    }

    @Test func remembersTheLastOrganizerName() throws {
        let store = try makeStore()

        #expect(store.lastOrganizerName == nil)
        store.lastOrganizerName = "Ana"
        #expect(store.lastOrganizerName == "Ana")
    }

    @Test func remembersSavedRecoveryLinksPerGroup() throws {
        let store = try makeStore()
        let group = GroupID(rawValue: "g1")

        #expect(store.isRecoveryLinkSaved(for: group) == false)
        store.markRecoveryLinkSaved(for: group)
        store.markRecoveryLinkSaved(for: group)

        #expect(store.isRecoveryLinkSaved(for: group))
        #expect(store.isRecoveryLinkSaved(for: GroupID(rawValue: "g2")) == false)
    }
}
