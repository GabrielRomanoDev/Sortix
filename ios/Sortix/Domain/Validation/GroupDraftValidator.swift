/// Validates the group being created (BR-01 to BR-17). Each method checks one field, so screens
/// can show the error next to it; `isValid(_:today:)` checks everything before the draw.
enum GroupDraftValidator {
    static func validateName(_ name: String) -> ValidationError? {
        validateText(name, limit: FieldLimits.groupName, isRequired: true)
    }

    static func validateMaxGiftValue(_ value: Money?) -> ValidationError? {
        guard let value else { return nil }
        let isInRange = (1...FieldLimits.maxGiftValueMinor).contains(value.amountMinor)
        return isInRange ? nil : .outOfRange
    }

    /// - Parameter today: Today in the organizer's calendar, passed in so tests can fix it.
    static func validateEventDate(_ date: CalendarDate?, today: CalendarDate) -> ValidationError? {
        guard let date else { return nil }
        return date < today ? .dateInPast : nil
    }

    static func validateLocation(_ location: String?) -> ValidationError? {
        validateText(location ?? "", limit: FieldLimits.location, isRequired: false)
    }

    static func validateNotes(_ notes: String?) -> ValidationError? {
        validateText(notes ?? "", limit: FieldLimits.groupNotes, isRequired: false)
    }

    /// Checks a participant's name, including duplicates among the other participants (BR-10).
    static func validateParticipantName(
        _ participant: ParticipantDraft,
        among participants: [ParticipantDraft]
    ) -> ValidationError? {
        if let error = validateText(participant.name, limit: FieldLimits.participantName, isRequired: true) {
            return error
        }
        let normalizedName = NameNormalizer.normalize(participant.name)
        let isDuplicated = participants.contains { other in
            other.id != participant.id && NameNormalizer.normalize(other.name) == normalizedName
        }
        return isDuplicated ? .duplicated : nil
    }

    static func validateParticipantCount(_ count: Int) -> ValidationError? {
        let isInRange = (FieldLimits.minParticipants...FieldLimits.maxParticipants).contains(count)
        return isInRange ? nil : .outOfRange
    }

    /// Checks that the organizer appears exactly once and that restrictions only mention other
    /// existing participants.
    static func validateParticipants(_ participants: [ParticipantDraft]) -> ValidationError? {
        let organizerCount = participants.filter(\.isOrganizer).count
        if organizerCount != 1 {
            return .invalidOrganizer
        }
        let ids = Set(participants.map(\.id))
        for participant in participants {
            let mentionsThemselves = participant.forbiddenGiverIDs.contains(participant.id)
            let mentionsUnknown = !participant.forbiddenGiverIDs.isSubset(of: ids)
            if mentionsThemselves || mentionsUnknown {
                return .invalidRestriction
            }
        }
        return nil
    }

    static func isValid(_ draft: GroupDraft, today: CalendarDate) -> Bool {
        let fieldErrors: [ValidationError?] = [
            validateName(draft.name),
            validateMaxGiftValue(draft.rules.maxGiftValue),
            validateEventDate(draft.rules.eventDate, today: today),
            validateLocation(draft.rules.location),
            validateNotes(draft.rules.notes),
            validateParticipantCount(draft.participants.count),
            validateParticipants(draft.participants)
        ]
        let nameErrors = draft.participants.map { validateParticipantName($0, among: draft.participants) }
        return (fieldErrors + nameErrors).allSatisfy { $0 == nil }
    }

    private static func validateText(_ text: String, limit: Int, isRequired: Bool) -> ValidationError? {
        let trimmed = text.trimmed
        if trimmed.isEmpty {
            return isRequired ? .empty : nil
        }
        return trimmed.count > limit ? .tooLong(limit: limit) : nil
    }
}
