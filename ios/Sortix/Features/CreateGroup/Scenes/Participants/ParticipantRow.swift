/// One person in the participants list, ready to display.
struct ParticipantRow: Equatable {
    let id: ParticipantID
    let name: String
    /// Position in the group, which picks the avatar colors.
    let colorIndex: Int
    /// Who this person cannot draw, in list order (BR-14).
    let forbiddenReceivers: [ParticipantBadge]
    /// A problem with the name, shown on the row. An empty organizer name is not an error: the row
    /// shows a hint instead.
    let error: ValidationError?
}

/// A person shown inside another person's row or screen, such as a restriction.
struct ParticipantBadge: Equatable {
    let name: String
    /// Position in the group, which picks the avatar colors.
    let colorIndex: Int
}
