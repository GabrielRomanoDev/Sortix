/// Runs the draw for the review screen.
protocol DrawServiceProtocol: Sendable {
    func draw(_ input: DrawInput) async -> Result<Assignment, DrawFailure>
}
