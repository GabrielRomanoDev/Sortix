/// Another participant who may or may not draw the person being edited.
struct RestrictionOption: Equatable {
    let giverID: ParticipantID
    let name: String
    /// `true` when this participant cannot draw the person being edited.
    let isSelected: Bool
}
