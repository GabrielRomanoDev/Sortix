import FirebaseAuth

/// Anonymous sign-in with Firebase Auth. The UID survives app restarts, so the organizer keeps
/// their groups on this device.
// `Auth` is documented as thread-safe, which makes the unchecked conformance safe.
final class FirebaseAuthService: AuthServiceProtocol, @unchecked Sendable {
    private let auth: Auth

    init(auth: Auth) {
        self.auth = auth
    }

    func ensureSignedIn() async throws -> UserID {
        if let user = auth.currentUser {
            return UserID(rawValue: user.uid)
        }
        return try await signInAnonymously()
    }

    private func signInAnonymously() async throws -> UserID {
        do {
            let result = try await auth.signInAnonymously()
            return UserID(rawValue: result.user.uid)
        } catch {
            throw FirebaseErrorMapper.serviceError(from: error, operation: .signIn)
        }
    }
}
