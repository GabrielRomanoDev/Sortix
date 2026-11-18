import Testing
@testable import Sortix

/// Cases T1 to T16 from section 10.8 of the specification.
struct DrawEngineTests {
    private typealias Helpers = DrawTestHelpers

    private func draw(
        _ input: DrawInput,
        seed: UInt64 = 42,
        configuration: DrawEngineConfiguration = DrawEngineConfiguration()
    ) -> Result<Assignment, DrawFailure> {
        var generator = SeededRandomNumberGenerator(seed: seed)
        return DrawEngine(configuration: configuration).draw(input, using: &generator)
    }

    @Test func t01ThreePeopleFormOneCycle() throws {
        let input = Helpers.input(["A", "B", "C"])
        let assignment = try draw(input).get()

        #expect(AssignmentValidator.isValid(assignment, for: input))
        #expect(Helpers.cycleLengths(of: assignment) == [3])
    }

    @Test func t02SinglePossibleResult() throws {
        let input = Helpers.input(["Mãe", "Pedro", "Pai"], forbidden: ["Mãe": ["Pedro"]])
        let expected = Assignment(receiverByGiver: [
            Helpers.id("Mãe"): Helpers.id("Pedro"),
            Helpers.id("Pedro"): Helpers.id("Pai"),
            Helpers.id("Pai"): Helpers.id("Mãe")
        ])

        for seed in UInt64(1)...20 {
            #expect(try draw(input, seed: seed).get() == expected)
        }
    }

    @Test func t03TwoReceiversShareOneGiver() {
        let input = Helpers.input(["Mãe", "Pedro", "Pai"], forbidden: ["Mãe": ["Pedro"], "Pedro": ["Mãe"]])

        #expect(draw(input) == .failure(.receiversShareTooFewGivers(
            receivers: [Helpers.id("Mãe"), Helpers.id("Pedro")],
            givers: [Helpers.id("Pai")]
        )))
    }

    @Test func t04FourPeopleCyclesAreUniform() throws {
        let names = ["A", "B", "C", "D"]
        let input = Helpers.input(names)
        var counts: [String: Int] = [:]

        for seed in UInt64(1)...6_000 {
            let assignment = try draw(input, seed: seed).get()
            #expect(Helpers.cycleLengths(of: assignment) == [4])
            let key = names.compactMap { assignment.receiverByGiver[Helpers.id($0)]?.rawValue }.joined()
            counts[key, default: 0] += 1
        }

        #expect(counts.count == 6)
        #expect(counts.values.allSatisfy { (850...1_150).contains($0) })
    }

    @Test func t05FivePeopleAlwaysFormOneCycle() throws {
        let input = Helpers.input(Helpers.names(count: 5))

        for seed in UInt64(1)...200 {
            #expect(Helpers.cycleLengths(of: try draw(input, seed: seed).get()) == [5])
        }
    }

    @Test func t06SixPeopleUseBothShapes() throws {
        let input = Helpers.input(Helpers.names(count: 6))
        var oneCycle = 0
        var twoCycles = 0

        for seed in UInt64(1)...2_000 {
            let lengths = Helpers.cycleLengths(of: try draw(input, seed: seed).get())
            if lengths == [6] { oneCycle += 1 }
            if lengths == [3, 3] { twoCycles += 1 }
        }

        #expect(oneCycle + twoCycles == 2_000)
        #expect((1_275...1_725).contains(oneCycle))
        #expect((425...575).contains(twoCycles))
    }

    @Test func t07NobodyCanDrawX() {
        let input = Helpers.input(["X", "A", "B", "C"], forbidden: ["X": ["A", "B", "C"]])

        #expect(draw(input) == .failure(.receiverWithoutGivers(Helpers.id("X"))))
    }

    @Test func t08XCannotDrawAnybody() {
        let input = Helpers.input(["X", "A", "B", "C"], forbidden: ["A": ["X"], "B": ["X"], "C": ["X"]])

        #expect(draw(input) == .failure(.giverWithoutReceivers(Helpers.id("X"))))
    }

    @Test func t09ThreeReceiversShareTwoGivers() {
        let input = Helpers.input(
            ["A", "B", "C", "D", "E", "F"],
            forbidden: ["A": ["B", "C", "F"], "B": ["A", "C", "F"], "C": ["A", "B", "F"]]
        )

        #expect(draw(input) == .failure(.receiversShareTooFewGivers(
            receivers: [Helpers.id("A"), Helpers.id("B"), Helpers.id("C")],
            givers: [Helpers.id("D"), Helpers.id("E")]
        )))
    }

    @Test func t10OnlyMutualPairsAreAllowed() {
        let input = Helpers.input(
            ["A", "B", "C", "D"],
            forbidden: ["A": ["C", "D"], "B": ["C", "D"], "C": ["A", "B"], "D": ["A", "B"]]
        )

        #expect(draw(input) == .failure(.onlyMutualPairs))
    }

    @Test func t11FiftyPeopleWithoutRestrictionsIsFast() throws {
        let input = Helpers.input(Helpers.names(count: 50))
        var result: Result<Assignment, DrawFailure>?

        let duration = ContinuousClock().measure { result = draw(input) }

        #expect(AssignmentValidator.isValid(try #require(result).get(), for: input))
        #expect(duration < .milliseconds(100))
    }

    @Test func t12FiftyPeopleWithRestrictionsIsFast() throws {
        let names = Helpers.names(count: 50)
        var generator = SeededRandomNumberGenerator(seed: 7)
        var forbidden: [String: [String]] = [:]
        for receiver in names {
            let others = names.filter { $0 != receiver }.shuffled(using: &generator)
            forbidden[receiver] = Array(others.prefix(5))
        }
        let input = Helpers.input(names, forbidden: forbidden)
        var result: Result<Assignment, DrawFailure>?

        let duration = ContinuousClock().measure { result = draw(input) }

        #expect(AssignmentValidator.isValid(try #require(result).get(), for: input))
        #expect(duration < .milliseconds(100))
    }

    @Test func t13SameSeedGivesSameResult() {
        let input = Helpers.input(Helpers.names(count: 10), forbidden: ["P1": ["P2"], "P3": ["P4"]])

        #expect(draw(input, seed: 99) == draw(input, seed: 99))
    }

    @Test func t14RandomInputsAreValidOrExplained() {
        var generator = SeededRandomNumberGenerator(seed: 2026)

        for seed in UInt64(1)...300 {
            let names = Helpers.names(count: Int.random(in: 3...12, using: &generator))
            var forbidden: [String: [String]] = [:]
            for receiver in names {
                forbidden[receiver] = names.filter { giver in
                    giver != receiver && Double.random(in: 0..<1, using: &generator) < 0.3
                }
            }
            let input = Helpers.input(names, forbidden: forbidden)

            switch draw(input, seed: seed) {
            case .success(let assignment):
                #expect(AssignmentValidator.isValid(assignment, for: input))
            case .failure(let failure):
                #expect(isExplainable(failure), "Unexpected failure: \(failure)")
            }
        }
    }

    @Test func t15SearchFindsAResultWithoutSampling() throws {
        let names = Helpers.names(count: 7)
        var forbidden: [String: [String]] = [:]
        for (index, receiver) in names.enumerated() {
            forbidden[receiver] = [names[(index + names.count - 1) % names.count]]
        }
        let input = Helpers.input(names, forbidden: forbidden)
        let configuration = DrawEngineConfiguration(maxRejectionAttempts: 0)

        let assignment = try draw(input, configuration: configuration).get()

        #expect(AssignmentValidator.isValid(assignment, for: input))
    }

    @Test func t16SearchStopsAtItsLimit() {
        let input = Helpers.input(Helpers.names(count: 7))
        let configuration = DrawEngineConfiguration(maxRejectionAttempts: 0, maxSearchSteps: 1)

        #expect(draw(input, configuration: configuration) == .failure(.searchLimitReached))
    }

    private func isExplainable(_ failure: DrawFailure) -> Bool {
        switch failure {
        case .receiverWithoutGivers, .giverWithoutReceivers, .receiversShareTooFewGivers, .onlyMutualPairs:
            true
        case .notEnoughParticipants, .searchLimitReached:
            false
        }
    }
}
