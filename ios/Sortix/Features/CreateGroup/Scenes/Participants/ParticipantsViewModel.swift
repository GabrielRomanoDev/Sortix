import Foundation

/// Drives step 2 of the creation flow: the participant list (BR-08 to BR-13, BR-16).
///
/// The organizer is always the first participant. Every change is written to the draft store.
@MainActor
final class ParticipantsViewModel {
    enum Navigation {
        case openParticipant(ParticipantID)
        /// The coordinator shows the contact picker and calls `onPicked` with the contact's name,
        /// or with `nil` when the contact has no name.
        case pickContact(onPicked: @MainActor (String?) -> Void)
        case review
    }

    var onStateChange: ((ParticipantsState) -> Void)?
    var onNavigation: ((Navigation) -> Void)?

    private(set) var state = ParticipantsState()

    /// Used to join names in the restrictions summary.
    let locale: Locale

    private let draftStore: CreateGroupDraftStore
    private let settingsStore: any LocalSettingsStoreProtocol
    private var newName = ""
    private var addError: ParticipantsState.AddError?

    init(draftStore: CreateGroupDraftStore, settingsStore: any LocalSettingsStoreProtocol, locale: Locale) {
        self.draftStore = draftStore
        self.settingsStore = settingsStore
        self.locale = locale
    }

    func viewDidLoad() {
        addOrganizerIfNeeded()
        updateState(makeState())
    }

    // MARK: - Adding

    func didChangeNewName(_ name: String) {
        newName = name
        addError = nil
        updateState(makeState())
    }

    /// The add field's return key.
    func didTapAdd() {
        let name = newName.trimmed
        guard !name.isEmpty else { return }
        if let error = validateNewName(name, allowsLongName: false) {
            addError = error
        } else {
            append(name)
            newName = ""
        }
        updateState(makeState())
    }

    func didTapAddFromContacts() {
        guard canAddMore else { return }
        onNavigation?(.pickContact(onPicked: { [weak self] name in
            self?.didPickContact(named: name)
        }))
    }

    /// A contact's name longer than the limit is still added, flagged for the organizer to
    /// shorten (BR-13).
    private func didPickContact(named name: String?) {
        let trimmedName = name?.trimmed ?? ""
        if trimmedName.isEmpty {
            addError = .contactWithoutName
        } else if let error = validateNewName(trimmedName, allowsLongName: true) {
            addError = error
        } else {
            append(trimmedName)
        }
        updateState(makeState())
    }

    // MARK: - Other actions

    /// Removes a participant and every restriction that mentions them (BR-16).
    func didRemove(_ id: ParticipantID) {
        draftStore.removeParticipant(id)
        addError = nil
        updateState(makeState())
    }

    func didSelect(_ id: ParticipantID) {
        onNavigation?(.openParticipant(id))
    }

    func didTapReview() {
        guard state.isReviewEnabled else { return }
        onNavigation?(.review)
    }

    /// Called when the screen shows again, e.g. after editing a participant in the detail screen.
    func viewWillAppear() {
        updateState(makeState())
    }

    // MARK: - Rules

    private var canAddMore: Bool {
        draftStore.draft.participants.count < FieldLimits.maxParticipants
    }

    private func validateNewName(_ name: String, allowsLongName: Bool) -> ParticipantsState.AddError? {
        if !canAddMore {
            return .limitReached
        }
        if !allowsLongName && name.count > FieldLimits.participantName {
            return .nameTooLong(limit: FieldLimits.participantName)
        }
        let normalizedName = NameNormalizer.normalize(name)
        let isDuplicated = draftStore.draft.participants.contains { participant in
            NameNormalizer.normalize(participant.name) == normalizedName
        }
        return isDuplicated ? .duplicate : nil
    }

    private func append(_ name: String) {
        let participant = ParticipantDraft(
            id: ParticipantID(rawValue: UUID().uuidString),
            name: name,
            isOrganizer: false
        )
        draftStore.draft.participants.append(participant)
        addError = nil
    }

    /// The organizer takes part in every group, prefilled with the last name used (BR-11).
    private func addOrganizerIfNeeded() {
        guard !draftStore.draft.participants.contains(where: \.isOrganizer) else { return }
        let organizer = ParticipantDraft(
            id: ParticipantID(rawValue: UUID().uuidString),
            name: settingsStore.lastOrganizerName ?? "",
            isOrganizer: true
        )
        draftStore.draft.participants.insert(organizer, at: 0)
    }

    // MARK: - State

    private func makeState() -> ParticipantsState {
        let participants = draftStore.draft.participants

        var state = ParticipantsState()
        state.organizer = participants.first(where: \.isOrganizer).map { makeRow(for: $0, among: participants) }
        state.participants = participants.filter { !$0.isOrganizer }.map { makeRow(for: $0, among: participants) }
        state.newName = newName
        state.isAddEnabled = canAddMore
        state.addError = addError ?? (canAddMore ? nil : .limitReached)
        state.count = participants.count
        state.isReviewEnabled = isReviewEnabled(participants)
        return state
    }

    private func makeRow(for participant: ParticipantDraft, among participants: [ParticipantDraft]) -> ParticipantRow {
        let error = GroupDraftValidator.validateParticipantName(participant, among: participants)
        // Restrictions are stored on who is drawn, but shown from the side of who draws.
        let receiverNames = participants
            .filter { $0.forbiddenGiverIDs.contains(participant.id) }
            .map(\.name)
        return ParticipantRow(
            id: participant.id,
            name: participant.name,
            forbiddenReceiverNames: receiverNames,
            error: error == .empty ? nil : error
        )
    }

    private func isReviewEnabled(_ participants: [ParticipantDraft]) -> Bool {
        let hasEnoughPeople = GroupDraftValidator.validateParticipantCount(participants.count) == nil
        let namesAreValid = participants.allSatisfy {
            GroupDraftValidator.validateParticipantName($0, among: participants) == nil
        }
        return hasEnoughPeople && namesAreValid
    }

    private func updateState(_ newState: ParticipantsState) {
        state = newState
        onStateChange?(newState)
    }
}
