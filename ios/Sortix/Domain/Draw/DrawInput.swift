/// What the draw needs: the participants and the restrictions. Already validated by
/// `GroupDraftValidator`, so the engine does not repeat form checks.
struct DrawInput: Equatable, Sendable {
    /// The participants in list order. The engine always walks this array, never dictionary keys,
    /// so the same seed gives the same result.
    let participantIDs: [ParticipantID]
    /// Receivers mapped to the givers who cannot draw them (BR-14).
    let forbiddenGivers: [ParticipantID: Set<ParticipantID>]
}
