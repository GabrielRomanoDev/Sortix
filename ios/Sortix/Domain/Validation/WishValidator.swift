/// Validates a gift suggestion (BR-38 and BR-39). Each method checks one field, so the form can
/// show the error next to it.
enum WishValidator {
    static func validateDescription(_ text: String) -> ValidationError? {
        validateText(text, limit: FieldLimits.wishDescription, isRequired: true)
    }

    static func validateSize(_ text: String) -> ValidationError? {
        validateText(text, limit: FieldLimits.wishSize, isRequired: false)
    }

    static func validateColor(_ text: String) -> ValidationError? {
        validateText(text, limit: FieldLimits.wishColor, isRequired: false)
    }

    static func validateNotes(_ text: String) -> ValidationError? {
        validateText(text, limit: FieldLimits.wishNotes, isRequired: false)
    }

    /// An empty link is valid; a filled one must normalize to `http` or `https`.
    static func validateLink(_ text: String) -> ValidationError? {
        if text.isBlank {
            return nil
        }
        guard let link = LinkNormalizer.normalize(text) else {
            return .invalidLink
        }
        return link.count > FieldLimits.wishLink ? .tooLong(limit: FieldLimits.wishLink) : nil
    }

    static func isValid(_ draft: WishDraft) -> Bool {
        let errors = [
            validateDescription(draft.description),
            validateSize(draft.size),
            validateColor(draft.color),
            validateNotes(draft.notes),
            validateLink(draft.link)
        ]
        return errors.allSatisfy { $0 == nil }
    }

    private static func validateText(_ text: String, limit: Int, isRequired: Bool) -> ValidationError? {
        let trimmed = text.trimmed
        if trimmed.isEmpty {
            return isRequired ? .empty : nil
        }
        return trimmed.count > limit ? .tooLong(limit: limit) : nil
    }
}
