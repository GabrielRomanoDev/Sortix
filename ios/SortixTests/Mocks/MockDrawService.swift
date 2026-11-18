@testable import Sortix

/// Returns a fixed draw result, so screens can be tested without running the engine.
struct MockDrawService: DrawServiceProtocol {
    var result: Result<Assignment, DrawFailure> = .failure(.onlyMutualPairs)

    func draw(_ input: DrawInput) async -> Result<Assignment, DrawFailure> {
        result
    }
}
