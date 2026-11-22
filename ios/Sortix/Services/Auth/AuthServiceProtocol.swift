/// Gives every request an anonymous Firebase user (flow 4.1). The security rules need one.
protocol AuthServiceProtocol: Sendable {
    /// Returns the current user, signing in anonymously first when there is none.
    func ensureSignedIn() async throws -> UserID
}
