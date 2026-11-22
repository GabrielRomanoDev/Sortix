import FirebaseCrashlytics
import Foundation

/// Records non-fatal errors in Crashlytics.
// `Crashlytics` is documented as thread-safe, which makes the unchecked conformance safe.
final class CrashlyticsReporter: CrashReporterProtocol, @unchecked Sendable {
    private let crashlytics: Crashlytics

    init(crashlytics: Crashlytics) {
        self.crashlytics = crashlytics
    }

    func recordNonFatal(_ error: any Error, context: [String: String]) {
        crashlytics.record(error: sanitized(error), userInfo: context)
    }

    // Firebase error descriptions can contain document paths, and paths contain tokens (BR-55).
    // Only the domain and the code are sent, which is enough to group the reports.
    private func sanitized(_ error: any Error) -> NSError {
        let nsError = error as NSError
        return NSError(domain: nsError.domain, code: nsError.code)
    }
}
