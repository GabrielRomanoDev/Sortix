/// Reason codes shared by the app and the website (section 13.2 of the specification).
///
/// The raw values must stay identical to `web/js/errors.js`. They are the only error information
/// allowed in Crashlytics context, because they never carry names, tokens or suggestions (BR-55).
enum ServiceErrorReason: String, Sendable {
    case invalidToken = "INVALID_TOKEN"
    case linkNotFound = "LINK_NOT_FOUND"
    case organizerLinkBlocked = "ORGANIZER_LINK_BLOCKED"
    case groupNotFound = "GROUP_NOT_FOUND"
    case notOrganizer = "NOT_ORGANIZER"
    case wishLimitReached = "WISH_LIMIT_REACHED"
    case wishNotFound = "WISH_NOT_FOUND"
    case network = "NETWORK"
    case quotaExceeded = "QUOTA_EXCEEDED"
    /// App only: anonymous sign-in failed or the session was lost. The website never sends it.
    case unauthenticated = "UNAUTHENTICATED"
    case unknown = "UNKNOWN"
}
