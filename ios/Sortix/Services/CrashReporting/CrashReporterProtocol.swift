/// Sends unexpected, non-fatal errors to the crash reporting service.
///
/// `context` may contain only codes, such as a `reason`, a Function name or a screen name. Never
/// names, tokens, suggestions or draw results (BR-55).
protocol CrashReporterProtocol: Sendable {
    func recordNonFatal(_ error: any Error, context: [String: String])
}
