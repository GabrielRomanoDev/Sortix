import Testing
@testable import Sortix

struct GroupDraftValidatorTests {
    private let today = CalendarDate(year: 2026, month: 12, day: 10)

    // MARK: - Name

    @Test func nameIsRequired() {
        #expect(GroupDraftValidator.validateName("") == .empty)
        #expect(GroupDraftValidator.validateName("   ") == .empty)
    }

    @Test func nameAllows50CharactersCountingEmojiAsOne() {
        let fifty = String(repeating: "a", count: 49) + "🎄"
        let fiftyOne = fifty + "a"

        #expect(GroupDraftValidator.validateName(fifty) == nil)
        #expect(GroupDraftValidator.validateName(fiftyOne) == .tooLong(limit: 50))
    }

    // MARK: - Rules

    @Test(arguments: [(0, false), (1, true), (10_000_000, true), (10_000_001, false)])
    func maxGiftValueRange(amountMinor: Int, isValid: Bool) {
        let error = GroupDraftValidator.validateMaxGiftValue(Money(amountMinor: amountMinor, currencyCode: "BRL"))
        #expect((error == nil) == isValid)
    }

    @Test func eventDateCannotBeInThePast() {
        let yesterday = CalendarDate(year: 2026, month: 12, day: 9)
        let tomorrow = CalendarDate(year: 2026, month: 12, day: 11)

        #expect(GroupDraftValidator.validateEventDate(yesterday, today: today) == .dateInPast)
        #expect(GroupDraftValidator.validateEventDate(today, today: today) == nil)
        #expect(GroupDraftValidator.validateEventDate(tomorrow, today: today) == nil)
        #expect(GroupDraftValidator.validateEventDate(nil, today: today) == nil)
    }

    @Test func locationAndNotesLimits() {
        #expect(GroupDraftValidator.validateLocation(String(repeating: "a", count: 120)) == nil)
        #expect(GroupDraftValidator.validateLocation(String(repeating: "a", count: 121)) == .tooLong(limit: 120))
        #expect(GroupDraftValidator.validateNotes(String(repeating: "a", count: 500)) == nil)
        #expect(GroupDraftValidator.validateNotes(String(repeating: "a", count: 501)) == .tooLong(limit: 500))
        #expect(GroupDraftValidator.validateLocation(nil) == nil)
    }

    // MARK: - Participants

    @Test(arguments: [(2, false), (3, true), (50, true), (51, false)])
    func participantCountRange(count: Int, isValid: Bool) {
        #expect((GroupDraftValidator.validateParticipantCount(count) == nil) == isValid)
    }

    @Test func duplicatedNamesIgnoreCaseAccentsAndSpaces() {
        let ana = participant("Ana")
        let others = [ana, participant(" aná "), participant("Bruno")]

        #expect(GroupDraftValidator.validateParticipantName(others[1], among: others) == .duplicated)
        #expect(GroupDraftValidator.validateParticipantName(others[2], among: others) == nil)
    }

    @Test func participantNameLimit() {
        let twenty = participant(String(repeating: "a", count: 20))
        let twentyOne = participant(String(repeating: "a", count: 21))

        #expect(GroupDraftValidator.validateParticipantName(twenty, among: [twenty]) == nil)
        #expect(GroupDraftValidator.validateParticipantName(twentyOne, among: [twentyOne]) == .tooLong(limit: 20))
    }

    @Test func organizerMustAppearExactlyOnce() {
        let withoutOrganizer = [participant("Ana"), participant("Bruno"), participant("Carla")]
        let twoOrganizers = [participant("Ana", isOrganizer: true), participant("Bruno", isOrganizer: true)]

        #expect(GroupDraftValidator.validateParticipants(withoutOrganizer) == .invalidOrganizer)
        #expect(GroupDraftValidator.validateParticipants(twoOrganizers) == .invalidOrganizer)
    }

    @Test func restrictionsMustMentionOtherExistingParticipants() {
        let ana = participant("Ana", isOrganizer: true)
        var bruno = participant("Bruno")

        bruno.forbiddenGiverIDs = [bruno.id]
        #expect(GroupDraftValidator.validateParticipants([ana, bruno]) == .invalidRestriction)

        bruno.forbiddenGiverIDs = [ParticipantID(rawValue: "missing")]
        #expect(GroupDraftValidator.validateParticipants([ana, bruno]) == .invalidRestriction)

        bruno.forbiddenGiverIDs = [ana.id]
        #expect(GroupDraftValidator.validateParticipants([ana, bruno]) == nil)
    }

    @Test func completeDraftIsValid() {
        let draft = GroupDraft(
            name: "Família",
            rules: GroupRules(eventDate: today),
            participants: [participant("Ana", isOrganizer: true), participant("Bruno"), participant("Carla")]
        )

        #expect(GroupDraftValidator.isValid(draft, today: today))
    }

    private func participant(_ name: String, isOrganizer: Bool = false) -> ParticipantDraft {
        ParticipantDraft(id: ParticipantID(rawValue: name + "-id"), name: name, isOrganizer: isOrganizer)
    }
}
