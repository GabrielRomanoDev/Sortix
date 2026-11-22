/// One person in the participants list, ready to display.
struct ParticipantRow: Equatable {
    let id: ParticipantID
    let name: String
    /// Names of who cannot draw this person, in list order (BR-14).
    let restrictedGiverNames: [String]
    /// A problem with the name, shown on the row. An empty organizer name is not an error: the row
    /// shows a hint instead.
    let error: ValidationError?
}
