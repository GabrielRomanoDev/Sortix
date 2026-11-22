/// Errors services report to ViewModels. Firebase errors are converted into these cases by
/// `FirebaseErrorMapper`, so no layer above the services needs to know Firebase.
enum ServiceError: Error, Equatable, Sendable {
    case network
    case unauthenticated
    case invalidToken
    case linkNotFound
    case organizerLinkBlocked
    case notOrganizer
    case groupNotFound
    case wishLimitReached
    case wishNotFound
    case quotaExceeded
    case unknown

    /// Keeps a `ServiceError` as it is and treats any other error as `.unknown`.
    init(_ error: any Error) {
        if let serviceError = error as? ServiceError {
            self = serviceError
        } else {
            self = .unknown
        }
    }

    /// The code shared with the website, also used as Crashlytics context.
    var reason: ServiceErrorReason {
        switch self {
        case .network: .network
        case .unauthenticated: .unauthenticated
        case .invalidToken: .invalidToken
        case .linkNotFound: .linkNotFound
        case .organizerLinkBlocked: .organizerLinkBlocked
        case .notOrganizer: .notOrganizer
        case .groupNotFound: .groupNotFound
        case .wishLimitReached: .wishLimitReached
        case .wishNotFound: .wishNotFound
        case .quotaExceeded: .quotaExceeded
        case .unknown: .unknown
        }
    }
}
