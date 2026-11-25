/// Drives the participant detail: the name and who this person cannot draw (BR-09 to BR-15).
///
/// Changes are written to the draft store as soon as they are made, so Back keeps them too.
@MainActor
final class ParticipantDetailViewModel {
    enum Navigation {
        case done
        case removed
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

    /// The screen asks who this person cannot draw, but restrictions are stored on who is drawn
    /// (BR-14), so the receiver's list changes. They stay one-way.
    func didChangeRestriction(receiverID: ParticipantID, isSelected: Bool) {
        guard let receiverIndex = draftStore.draft.participants.firstIndex(where: { $0.id == receiverID }) else {
            return
        }
        if isSelected {
            draftStore.draft.participants[receiverIndex].forbiddenGiverIDs.insert(participantID)
        } else {
            draftStore.draft.participants[receiverIndex].forbiddenGiverIDs.remove(participantID)
        }
        updateState(makeState())
    }

    func didTapRemove() {
        guard state.canRemove else { return }
        draftStore.removeParticipant(participantID)
        onNavigation?(.removed)
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
        state.canRemove = !participant.isOrganizer
        state.options = draftStore.draft.participants.enumerated()
            .filter { $0.element.id != participantID }
            .map { position, receiver in
                RestrictionOption(
                    receiverID: receiver.id,
                    name: receiver.name,
                    colorIndex: position,
                    isSelected: receiver.forbiddenGiverIDs.contains(participantID)
                )
            }
        return state
    }

    private func updateState(_ newState: ParticipantDetailState) {
        state = newState
        onStateChange?(newState)
    }
}
