/// Computes a Secret Santa draw: everyone gives and receives exactly one gift, nobody draws
/// themselves, restrictions are respected and there are no mutual pairs (BR-18 to BR-21).
///
/// Steps (section 10.2): direct checks, perfect matching, random sampling and, if sampling does
/// not find a result, a backtracking search. Sampling gives every valid draw the same chance.
struct DrawEngine: Sendable {
    let configuration: DrawEngineConfiguration

    init(configuration: DrawEngineConfiguration = DrawEngineConfiguration()) {
        self.configuration = configuration
    }

    /// - Parameter generator: `SystemRandomNumberGenerator` in production, a seeded one in tests.
    func draw(
        _ input: DrawInput,
        using generator: inout some RandomNumberGenerator
    ) -> Result<Assignment, DrawFailure> {
        let ids = input.participantIDs
        guard ids.count >= FieldLimits.minParticipants else {
            return .failure(.notEnoughParticipants(minimum: FieldLimits.minParticipants))
        }

        let pairs = AllowedPairs(input)
        if let failure = directCheckFailure(pairs) {
            return .failure(failure)
        }
        if let violation = BipartiteMatcher(pairs: pairs).findHallViolation() {
            return .failure(.receiversShareTooFewGivers(
                receivers: Set(violation.receivers.map { ids[$0] }),
                givers: Set(violation.givers.map { ids[$0] })
            ))
        }
        if let receivers = sample(pairs, using: &generator) {
            return .success(makeAssignment(receivers, ids: ids))
        }

        var search = CycleCoverSearch(pairs: pairs, maxSteps: configuration.maxSearchSteps)
        switch search.run(using: &generator) {
        case .found(let receivers):
            return .success(makeAssignment(receivers, ids: ids))
        case .impossible:
            return .failure(.onlyMutualPairs)
        case .limitReached:
            return .failure(.searchLimitReached)
        }
    }

    // MARK: - Steps

    /// Someone nobody can draw, or someone who cannot draw anybody. The most common causes.
    private func directCheckFailure(_ pairs: AllowedPairs) -> DrawFailure? {
        let people = 0..<pairs.count
        for receiver in people where !people.contains(where: { pairs.isAllowed(giver: $0, receiver: receiver) }) {
            return .receiverWithoutGivers(pairs.participantIDs[receiver])
        }
        for giver in people where !people.contains(where: { pairs.isAllowed(giver: giver, receiver: $0) }) {
            return .giverWithoutReceivers(pairs.participantIDs[giver])
        }
        return nil
    }

    /// Shuffles the participants and keeps the first valid result. `receivers[g]` is the receiver
    /// of giver `g`; a shuffle is always a bijection, so only pairs and mutual pairs are checked.
    private func sample(_ pairs: AllowedPairs, using generator: inout some RandomNumberGenerator) -> [Int]? {
        var receivers = Array(0..<pairs.count)
        for _ in 0..<configuration.maxRejectionAttempts {
            receivers.shuffle(using: &generator)
            let isValid = receivers.indices.allSatisfy { giver in
                let receiver = receivers[giver]
                return pairs.isAllowed(giver: giver, receiver: receiver) && receivers[receiver] != giver
            }
            if isValid {
                return receivers
            }
        }
        return nil
    }

    private func makeAssignment(_ receivers: [Int], ids: [ParticipantID]) -> Assignment {
        var receiverByGiver: [ParticipantID: ParticipantID] = [:]
        for (giver, receiver) in receivers.enumerated() {
            receiverByGiver[ids[giver]] = ids[receiver]
        }
        return Assignment(receiverByGiver: receiverByGiver)
    }
}
