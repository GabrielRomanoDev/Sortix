/// Checks whether every receiver can get a different giver (a perfect matching), using Kuhn's
/// algorithm. When that fails, it returns the group that explains why (Hall's theorem).
struct BipartiteMatcher {
    let pairs: AllowedPairs

    /// Returns `nil` when a perfect matching exists. Otherwise returns receivers that can only be
    /// drawn by a smaller group of givers, as positions in the participant list.
    func findHallViolation() -> (receivers: [Int], givers: [Int])? {
        var giverMatches = [Int?](repeating: nil, count: pairs.count)
        for receiver in 0..<pairs.count {
            var visitedGivers = Set<Int>()
            if !assign(receiver, to: &giverMatches, visitedGivers: &visitedGivers) {
                return hallWitness(startingAt: receiver, giverMatches: giverMatches)
            }
        }
        return nil
    }

    /// Tries to give `receiver` a giver, moving earlier receivers to other givers if needed.
    /// `giverMatches[g]` is the receiver currently matched to giver `g`.
    private func assign(_ receiver: Int, to giverMatches: inout [Int?], visitedGivers: inout Set<Int>) -> Bool {
        for giver in 0..<pairs.count where pairs.isAllowed(giver: giver, receiver: receiver) {
            guard !visitedGivers.contains(giver) else { continue }
            visitedGivers.insert(giver)

            if let currentReceiver = giverMatches[giver] {
                guard assign(currentReceiver, to: &giverMatches, visitedGivers: &visitedGivers) else { continue }
            }
            giverMatches[giver] = receiver
            return true
        }
        return false
    }

    /// From a receiver left without a giver, collects everyone reachable through alternating
    /// paths. The receivers found can only be drawn by the givers found, and there is one fewer giver.
    private func hallWitness(startingAt start: Int, giverMatches: [Int?]) -> (receivers: [Int], givers: [Int]) {
        var receivers: Set<Int> = [start]
        var givers = Set<Int>()
        var queue = [start]

        while !queue.isEmpty {
            let receiver = queue.removeFirst()
            for giver in 0..<pairs.count where pairs.isAllowed(giver: giver, receiver: receiver) {
                guard !givers.contains(giver) else { continue }
                givers.insert(giver)
                if let matchedReceiver = giverMatches[giver], !receivers.contains(matchedReceiver) {
                    receivers.insert(matchedReceiver)
                    queue.append(matchedReceiver)
                }
            }
        }
        return (receivers.sorted(), givers.sorted())
    }
}
