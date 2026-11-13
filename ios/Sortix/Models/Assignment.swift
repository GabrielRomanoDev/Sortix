/// The result of a draw: who each participant gives a gift to.
///
/// It only travels from the draw to the `createGroup` call. The app never shows, logs or stores
/// it (product principle P3).
struct Assignment: Equatable, Sendable {
    let receiverByGiver: [ParticipantID: ParticipantID]
}
