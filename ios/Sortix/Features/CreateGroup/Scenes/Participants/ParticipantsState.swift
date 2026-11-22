/// Everything the participants screen shows.
struct ParticipantsState: Equatable {
    /// What the "Participantes" section footer says.
    enum Footer: Equatable {
        case count(Int)
        case duplicate
        case limitReached
        case contactWithoutName
        case nameTooLong(limit: Int)

        /// Everything except the count is an error, shown in red.
        var isError: Bool {
            if case .count = self {
                return false
            }
            return true
        }
    }

    var organizer: ParticipantRow?
    var participants: [ParticipantRow] = []
    /// The text in the add field. Cleared after a name is added.
    var newName = ""
    var footer = Footer.count(0)
    var isAddEnabled = true
    var isReviewEnabled = false
}
