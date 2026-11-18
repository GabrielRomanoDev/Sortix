/// Checks a draw result against BR-18 to BR-21. Mirrored in TypeScript by the `createGroup`
/// Function, which re-validates the draw before writing (section 10.7).
enum AssignmentValidator {
    static func isValid(_ assignment: Assignment, for input: DrawInput) -> Bool {
        let participants = Set(input.participantIDs)
        let receiverByGiver = assignment.receiverByGiver

        let givers = Set(receiverByGiver.keys)
        let receivers = Set(receiverByGiver.values)
        let isBijection = receiverByGiver.count == participants.count
            && givers == participants
            && receivers == participants
        guard isBijection else { return false }

        return receiverByGiver.allSatisfy { giver, receiver in
            let drawsThemselves = giver == receiver
            let isForbidden = input.forbiddenGivers[receiver]?.contains(giver) ?? false
            let isMutualPair = receiverByGiver[receiver] == giver
            return !drawsThemselves && !isForbidden && !isMutualPair
        }
    }
}
