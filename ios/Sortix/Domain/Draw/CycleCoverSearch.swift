/// Backtracking search for a valid draw, used when random sampling does not find one (many
/// restrictions). It also proves a draw is impossible when it ends without a result.
///
/// At each step it picks the giver with the fewest options, tries those options in random order
/// and backs off as soon as some receiver can no longer get a giver.
struct CycleCoverSearch {
    enum Outcome {
        /// `receivers[g]` is the receiver of giver `g`.
        case found(receivers: [Int])
        case impossible
        case limitReached
    }

    private let pairs: AllowedPairs
    private let maxSteps: Int
    private var receiverOf: [Int?]
    private var giverOf: [Int?]
    private var steps = 0
    private var isLimitReached = false

    init(pairs: AllowedPairs, maxSteps: Int) {
        self.pairs = pairs
        self.maxSteps = maxSteps
        receiverOf = Array(repeating: nil, count: pairs.count)
        giverOf = Array(repeating: nil, count: pairs.count)
    }

    mutating func run(using generator: inout some RandomNumberGenerator) -> Outcome {
        if backtrack(using: &generator) {
            return .found(receivers: receiverOf.compactMap { $0 })
        }
        return isLimitReached ? .limitReached : .impossible
    }

    // MARK: - Search

    private mutating func backtrack(using generator: inout some RandomNumberGenerator) -> Bool {
        steps += 1
        if steps > maxSteps {
            isLimitReached = true
            return false
        }

        let freeGivers = (0..<pairs.count).filter { receiverOf[$0] == nil }
        guard !freeGivers.isEmpty else { return true }

        let giver = giverWithFewestOptions(among: freeGivers, using: &generator)
        var candidates = options(for: giver)
        candidates.shuffle(using: &generator)

        for receiver in candidates {
            receiverOf[giver] = receiver
            giverOf[receiver] = giver
            if isStillCoverable() && backtrack(using: &generator) {
                return true
            }
            if isLimitReached {
                return false
            }
            receiverOf[giver] = nil
            giverOf[receiver] = nil
        }
        return false
    }

    /// Receivers this giver may still take: allowed, not taken yet and not someone who already
    /// gives to this giver (that would be a mutual pair).
    private func options(for giver: Int) -> [Int] {
        (0..<pairs.count).filter { receiver in
            pairs.isAllowed(giver: giver, receiver: receiver)
                && giverOf[receiver] == nil
                && receiverOf[receiver] != giver
        }
    }

    private func giverWithFewestOptions(
        among givers: [Int],
        using generator: inout some RandomNumberGenerator
    ) -> Int {
        let optionCounts = givers.map { options(for: $0).count }
        let fewest = optionCounts.min() ?? 0
        let ties = zip(givers, optionCounts).filter { $0.1 == fewest }.map(\.0)
        return ties[Int.random(in: 0..<ties.count, using: &generator)]
    }

    /// Whether every receiver without a giver still has at least one possible giver.
    private func isStillCoverable() -> Bool {
        (0..<pairs.count).allSatisfy { receiver in
            guard giverOf[receiver] == nil else { return true }
            return (0..<pairs.count).contains { giver in
                receiverOf[giver] == nil
                    && pairs.isAllowed(giver: giver, receiver: receiver)
                    && receiverOf[receiver] != giver
            }
        }
    }
}
