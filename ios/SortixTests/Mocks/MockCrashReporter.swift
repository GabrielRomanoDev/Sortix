import os
@testable import Sortix

/// Records non-fatal errors so tests can check what would be sent to Crashlytics.
final class MockCrashReporter: CrashReporterProtocol {
    struct Record: Sendable {
        let error: any Error
        let context: [String: String]
    }

    // A lock keeps the mock `Sendable`, as the protocol requires, while it stores calls.
    private let lockedRecords = OSAllocatedUnfairLock(initialState: [Record]())

    var records: [Record] {
        lockedRecords.withLock { $0 }
    }

    func recordNonFatal(_ error: any Error, context: [String: String]) {
        lockedRecords.withLock { $0.append(Record(error: error, context: context)) }
    }
}
