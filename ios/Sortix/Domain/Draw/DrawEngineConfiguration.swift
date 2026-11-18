/// Effort limits of the draw. Tests lower them to force the search or its limit.
struct DrawEngineConfiguration: Sendable {
    var maxRejectionAttempts = 10_000
    var maxSearchSteps = 500_000
}
