import Foundation

/// Drives step 1 of the creation flow: the group name and the optional rules (BR-01 to BR-05).
///
/// Every change is written to the draft store right away and validated field by field.
@MainActor
final class GroupRulesViewModel {
    enum Navigation {
        case next
        case cancel
    }

    var onStateChange: ((GroupRulesState) -> Void)?
    var onNavigation: ((Navigation) -> Void)?

    private(set) var state = GroupRulesState()

    /// Used by the money field and the value limit message.
    let locale: Locale
    let currencyCode = "BRL"
    /// The earliest date the picker allows: today (BR-04).
    let minimumEventDate: Date?

    private let draftStore: CreateGroupDraftStore
    private let calendar: Calendar
    private let today: CalendarDate
    /// The empty name error waits until the person has typed something, so it never greets them.
    private var hasEditedName = false

    /// - Parameters:
    ///   - now: The current moment, passed in so tests can fix "today".
    init(draftStore: CreateGroupDraftStore, calendar: Calendar, locale: Locale, now: Date) {
        self.draftStore = draftStore
        self.calendar = calendar
        self.locale = locale
        let today = CalendarDate(date: now, calendar: calendar)
        self.today = today
        self.minimumEventDate = today.date(in: calendar)
    }

    func viewDidLoad() {
        hasEditedName = !draftStore.draft.name.isEmpty
        updateState(makeState())
    }

    // MARK: - Editing

    func didChangeName(_ name: String) {
        hasEditedName = true
        draftStore.draft.name = name
        updateState(makeState())
    }

    func didChangeMaxGiftValue(_ amountMinor: Int?) {
        draftStore.draft.rules.maxGiftValue = amountMinor.map { Money(amountMinor: $0, currencyCode: currencyCode) }
        updateState(makeState())
    }

    func didToggleEventDate(_ isOn: Bool) {
        draftStore.draft.rules.eventDate = isOn ? today : nil
        updateState(makeState())
    }

    func didChangeEventDate(_ date: Date) {
        draftStore.draft.rules.eventDate = CalendarDate(date: date, calendar: calendar)
        updateState(makeState())
    }

    func didChangeLocation(_ location: String) {
        draftStore.draft.rules.location = location
        updateState(makeState())
    }

    func didChangeNotes(_ notes: String) {
        draftStore.draft.rules.notes = notes
        updateState(makeState())
    }

    // MARK: - Navigation

    func didTapNext() {
        guard state.isNextEnabled else { return }
        onNavigation?(.next)
    }

    func didTapCancel() {
        onNavigation?(.cancel)
    }

    // MARK: - State

    private func makeState() -> GroupRulesState {
        let draft = draftStore.draft
        var state = GroupRulesState(
            name: draft.name,
            maxGiftValue: draft.rules.maxGiftValue,
            eventDate: draft.rules.eventDate?.date(in: calendar),
            location: draft.rules.location ?? "",
            notes: draft.rules.notes ?? ""
        )
        let nameError = GroupDraftValidator.validateName(draft.name)
        state.nameError = hasEditedName ? nameError : nil
        state.maxGiftValueError = GroupDraftValidator.validateMaxGiftValue(draft.rules.maxGiftValue)
        state.eventDateError = GroupDraftValidator.validateEventDate(draft.rules.eventDate, today: today)
        state.locationError = GroupDraftValidator.validateLocation(draft.rules.location)
        state.notesError = GroupDraftValidator.validateNotes(draft.rules.notes)

        let otherErrors = [state.maxGiftValueError, state.eventDateError, state.locationError, state.notesError]
        state.isNextEnabled = nameError == nil && otherErrors.allSatisfy { $0 == nil }
        return state
    }

    private func updateState(_ newState: GroupRulesState) {
        state = newState
        onStateChange?(newState)
    }
}
