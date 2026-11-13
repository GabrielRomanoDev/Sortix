/// Size limits of every field. Must stay identical to `backend/functions/src/domain/limits.ts`.
///
/// Text limits count characters as people see them (grapheme clusters, `String.count`), so an
/// emoji counts as one character.
enum FieldLimits {
    static let groupName = 50
    static let participantName = 20
    static let location = 120
    static let groupNotes = 500

    static let minParticipants = 3
    static let maxParticipants = 50

    /// R$ 100.000,00 in cents (BR-03).
    static let maxGiftValueMinor = 10_000_000

    static let wishDescription = 100
    static let wishSize = 20
    static let wishColor = 30
    static let wishNotes = 280
    static let wishLink = 2_000
    static let maxWishes = 5
}
