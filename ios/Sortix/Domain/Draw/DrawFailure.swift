/// Why a draw is impossible (section 10.5). The review screen turns each case into a message.
enum DrawFailure: Error, Equatable, Sendable {
    case notEnoughParticipants(minimum: Int)
    /// Nobody can draw this participant.
    case receiverWithoutGivers(ParticipantID)
    /// This participant cannot draw anybody.
    case giverWithoutReceivers(ParticipantID)
    /// These receivers can only be drawn by a smaller group of givers.
    case receiversShareTooFewGivers(receivers: Set<ParticipantID>, givers: Set<ParticipantID>)
    /// A draw exists only with mutual pairs, which are forbidden (BR-20).
    case onlyMutualPairs
    /// The search gave up before finding a result. Not expected with up to 50 people.
    case searchLimitReached
}
