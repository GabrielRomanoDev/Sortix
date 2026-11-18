import Testing
@testable import Sortix

struct AssignmentValidatorTests {
    private typealias Helpers = DrawTestHelpers

    private let input = Helpers.input(["A", "B", "C", "D"], forbidden: ["A": ["D"]])

    private func assignment(_ pairs: [(String, String)]) -> Assignment {
        var receiverByGiver: [ParticipantID: ParticipantID] = [:]
        for (giver, receiver) in pairs {
            receiverByGiver[Helpers.id(giver)] = Helpers.id(receiver)
        }
        return Assignment(receiverByGiver: receiverByGiver)
    }

    @Test func validCycle() {
        #expect(AssignmentValidator.isValid(assignment([("A", "C"), ("C", "D"), ("D", "B"), ("B", "A")]), for: input))
    }

    @Test func brokenBijection() {
        #expect(!AssignmentValidator.isValid(assignment([("A", "C"), ("B", "C"), ("C", "D"), ("D", "B")]), for: input))
    }

    @Test func selfAssignment() {
        #expect(!AssignmentValidator.isValid(assignment([("A", "A"), ("B", "C"), ("C", "D"), ("D", "B")]), for: input))
    }

    @Test func mutualPair() {
        #expect(!AssignmentValidator.isValid(assignment([("A", "B"), ("B", "A"), ("C", "D"), ("D", "C")]), for: input))
    }

    @Test func violatedRestriction() {
        // D cannot draw A.
        #expect(!AssignmentValidator.isValid(assignment([("D", "A"), ("A", "C"), ("C", "B"), ("B", "D")]), for: input))
    }

    @Test func missingParticipant() {
        #expect(!AssignmentValidator.isValid(assignment([("A", "B"), ("B", "C"), ("C", "A")]), for: input))
    }

    @Test func extraParticipant() {
        let pairs = [("A", "C"), ("C", "D"), ("D", "B"), ("B", "E"), ("E", "A")]
        #expect(!AssignmentValidator.isValid(assignment(pairs), for: input))
    }
}
