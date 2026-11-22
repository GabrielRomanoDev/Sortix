@testable import Sortix

/// Returns a fixed sign-in result, so screens can be tested without Firebase.
struct MockAuthService: AuthServiceProtocol {
    var result: Result<UserID, ServiceError> = .success(UserID(rawValue: "test-user"))

    func ensureSignedIn() async throws -> UserID {
        try result.get()
    }
}
