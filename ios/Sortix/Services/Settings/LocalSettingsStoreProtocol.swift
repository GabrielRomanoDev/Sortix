/// Small preferences kept only on this device.
@MainActor
protocol LocalSettingsStoreProtocol: AnyObject {
    /// Pre-fills the organizer field in the next group creation.
    var lastOrganizerName: String? { get set }
    func isRecoveryLinkSaved(for groupID: GroupID) -> Bool
    func markRecoveryLinkSaved(for groupID: GroupID)
}
