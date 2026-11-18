@testable import Sortix

/// Builds draw inputs from names, so test cases read like the table in section 10.8.
enum DrawTestHelpers {
    static func id(_ name: String) -> ParticipantID {
        ParticipantID(rawValue: name)
    }

    /// - Parameter forbidden: Receiver name mapped to the names of who cannot draw them.
    static func input(_ names: [String], forbidden: [String: [String]] = [:]) -> DrawInput {
        var forbiddenGivers: [ParticipantID: Set<ParticipantID>] = [:]
        for (receiver, givers) in forbidden {
            forbiddenGivers[id(receiver)] = Set(givers.map(id))
        }
        return DrawInput(participantIDs: names.map(id), forbiddenGivers: forbiddenGivers)
    }

    static func names(count: Int) -> [String] {
        (1...count).map { "P\($0)" }
    }

    /// Sizes of the cycles in a draw, sorted. A draw of 6 may be [6] or [3, 3].
    static func cycleLengths(of assignment: Assignment) -> [Int] {
        var remaining = Set(assignment.receiverByGiver.keys)
        var lengths: [Int] = []
        while let start = remaining.first {
            var length = 0
            var current = start
            repeat {
                remaining.remove(current)
                length += 1
                guard let next = assignment.receiverByGiver[current] else { break }
                current = next
            } while current != start
            lengths.append(length)
        }
        return lengths.sorted()
    }
}
