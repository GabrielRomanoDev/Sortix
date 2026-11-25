/// Everything the participants screen shows.
struct ParticipantsState: Equatable {
    /// Why the last name could not be added. Shown right below the add field.
    enum AddError: Equatable {
        case duplicate
        case limitReached
        case contactWithoutName
        case nameTooLong(limit: Int)
    }

    var organizer: ParticipantRow?
    var participants: [ParticipantRow] = []
    /// The text in the add field. Cleared after a name is added.
    var newName = ""
    var addError: AddError?
    /// Everyone in the group, including the organizer.
    var count = 0
    var isAddEnabled = true
    var isReviewEnabled = false
}
