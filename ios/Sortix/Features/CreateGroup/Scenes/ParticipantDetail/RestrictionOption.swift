/// Another participant the person being edited may or may not draw.
struct RestrictionOption: Equatable {
    let receiverID: ParticipantID
    let name: String
    /// Position in the group, which picks the avatar colors.
    let colorIndex: Int
    /// `true` when the person being edited cannot draw this participant.
    let isSelected: Bool
}
