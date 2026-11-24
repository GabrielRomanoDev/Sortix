/// Drives the participant detail: the name and who cannot draw this person (BR-09 to BR-15).
///
/// Changes are written to the draft store as soon as they are made, so Back keeps them too.
@MainActor
final class ParticipantDetailViewModel {
    enum Navigation {
        case done
    }

    var onStateChange: ((ParticipantDetailState) -> Void)?
    var onNavigation: ((Navigation) -> Void)?

    private(set) var state = ParticipantDetailState()

    private let draftStore: CreateGroupDraftStore
    private let settingsStore: any LocalSettingsStoreProtocol
    private let participantID: ParticipantID

    init(
        participantID: ParticipantID,
        draftStore: CreateGroupDraftStore,
        settingsStore: any LocalSettingsStoreProtocol
    ) {
        self.participantID = participantID
        self.draftStore = draftStore
        self.settingsStore = settingsStore
    }

    func viewDidLoad() {
        updateState(makeState())
    }

    func didChangeName(_ name: String) {
        guard let index = participantIndex() else { return }
        draftStore.draft.participants[index].name = name
        saveOrganizerNameIfValid(draftStore.draft.participants[index])
        updateState(makeState())
    }

    /// Restrictions are one-way: only this participant's list changes (BR-14).
    func didChangeRestriction(giverID: ParticipantID, isSelected: Bool) {
        guard let index = participantIndex() else { return }
        if isSelected {
            draftStore.draft.participants[index].forbiddenGiverIDs.insert(giverID)
        } else {
            draftStore.draft.participants[index].forbiddenGiverIDs.remove(giverID)
        }
        updateState(makeState())
    }

    func didTapDone() {
        guard state.isDoneEnabled else { return }
        onNavigation?(.done)
    }

    // MARK: - Helpers

    private func participantIndex() -> Int? {
        draftStore.draft.participants.firstIndex { $0.id == participantID }
    }

    /// The organizer's name comes prefilled in the next group (BR-11).
    private func saveOrganizerNameIfValid(_ participant: ParticipantDraft) {
        guard participant.isOrganizer, nameError(for: participant) == nil else { return }
        settingsStore.lastOrganizerName = participant.name.trimmed
    }

    private func nameError(for participant: ParticipantDraft) -> ValidationError? {
        GroupDraftValidator.validateParticipantName(participant, among: draftStore.draft.participants)
    }

    private func makeState() -> ParticipantDetailState {
        guard let index = participantIndex() else { return ParticipantDetailState() }
        let participant = draftStore.draft.participants[index]
        let error = nameError(for: participant)

        var state = ParticipantDetailState()
        state.name = participant.name
        state.isOrganizer = participant.isOrganizer
        state.nameError = error == .empty ? nil : error
        state.isDoneEnabled = error == nil
        state.options = draftStore.draft.participants
            .filter { $0.id != participantID }
            .map { giver in
                RestrictionOption(
                    giverID: giver.id,
                    name: giver.name,
                    isSelected: participant.forbiddenGiverIDs.contains(giver.id)
                )
            }
        return state
    }

    private func updateState(_ newState: ParticipantDetailState) {
        state = newState
        onStateChange?(newState)
    }
}
