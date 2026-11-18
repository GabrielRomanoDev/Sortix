/// Which giver may draw which receiver, by position in the participant list.
///
/// A pair is allowed when the giver is not the receiver and is not in the receiver's restrictions.
/// The draw works with positions (`Int`) instead of IDs because it is simpler and faster.
struct AllowedPairs {
    let participantIDs: [ParticipantID]
    private let allowed: [[Bool]]

    var count: Int { participantIDs.count }

    init(_ input: DrawInput) {
        let ids = input.participantIDs
        participantIDs = ids
        allowed = ids.map { giver in
            ids.map { receiver in
                let isForbidden = input.forbiddenGivers[receiver]?.contains(giver) ?? false
                return giver != receiver && !isForbidden
            }
        }
    }

    func isAllowed(giver: Int, receiver: Int) -> Bool {
        allowed[giver][receiver]
    }
}
