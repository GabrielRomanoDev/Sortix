/// Runs `DrawEngine` off the main thread with the system's secure random generator.
struct DrawService: DrawServiceProtocol {
    let engine: DrawEngine

    @concurrent
    func draw(_ input: DrawInput) async -> Result<Assignment, DrawFailure> {
        var generator = SystemRandomNumberGenerator()
        return engine.draw(input, using: &generator)
    }
}
