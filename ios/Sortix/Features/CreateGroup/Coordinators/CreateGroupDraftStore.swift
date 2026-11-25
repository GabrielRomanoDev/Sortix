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

    /// Removes a participant and every restriction that mentions them (BR-16). The organizer
    /// always takes part and is never removed (BR-11).
    func removeParticipant(_ id: ParticipantID) {
        draft.participants.removeAll { $0.id == id && !$0.isOrganizer }
        for index in draft.participants.indices {
            draft.participants[index].forbiddenGiverIDs.remove(id)
        }
    }
}
