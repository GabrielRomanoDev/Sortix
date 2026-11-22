/// Keeps the group being created while the person moves between the creation steps.
///
/// One instance per creation flow, owned by `CreateGroupCoordinator` and shared with each step's
/// ViewModel. It lives only in memory: leaving the flow discards it (BR-06).
@MainActor
final class CreateGroupDraftStore {
    var draft = GroupDraft()

    /// Whether anything was filled in, which makes leaving the flow ask for confirmation.
    var hasData: Bool {
        let rules = draft.rules
        return !draft.name.isBlank
            || rules.maxGiftValue != nil
            || rules.eventDate != nil
            || !(rules.location ?? "").isBlank
            || !(rules.notes ?? "").isBlank
            || !draft.participants.isEmpty
    }
}
