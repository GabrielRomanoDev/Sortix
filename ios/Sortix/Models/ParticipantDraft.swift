/// A participant being added in the creation flow.
struct ParticipantDraft: Identifiable, Equatable, Sendable {
    let id: ParticipantID
    var name: String
    let isOrganizer: Bool
    /// Who cannot draw this participant (BR-14). Restrictions live on the participant who is drawn.
    var forbiddenGiverIDs: Set<ParticipantID> = []
}
