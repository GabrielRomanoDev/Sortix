import FirebaseAuth
import FirebaseFirestore
import Foundation

/// Converts Firestore and Auth errors into `ServiceError` (table in section 13.2).
///
/// The same Firestore code can mean different things depending on the operation. For example,
/// `permission-denied` on a link means the organizer opened someone else's link, while on the
/// group it means this device is no longer the organizer.
enum FirebaseErrorMapper {
    /// The domain of every Firebase Auth error.
    private static let authErrorDomain = "FIRAuthErrorDomain"

    static func serviceError(from error: any Error, operation: ServiceOperation) -> ServiceError {
        if let serviceError = error as? ServiceError {
            return serviceError
        }

        let nsError = error as NSError
        switch nsError.domain {
        case FirestoreErrorDomain:
            return firestoreError(code: nsError.code, operation: operation)
        case authErrorDomain:
            return authError(code: nsError.code)
        default:
            return .unknown
        }
    }

    private static func firestoreError(code: Int, operation: ServiceOperation) -> ServiceError {
        guard let firestoreCode = FirestoreErrorCode.Code(rawValue: code) else {
            return .unknown
        }

        switch firestoreCode {
        case .unavailable, .deadlineExceeded:
            return .network
        case .resourceExhausted:
            return .quotaExceeded
        case .unauthenticated:
            return .unauthenticated
        case .permissionDenied:
            return permissionDeniedError(for: operation)
        case .notFound:
            return notFoundError(for: operation)
        default:
            return .unknown
        }
    }

    private static func authError(code: Int) -> ServiceError {
        if AuthErrorCode(rawValue: code) == .networkError {
            return .network
        }
        return .unauthenticated
    }

    private static func permissionDeniedError(for operation: ServiceOperation) -> ServiceError {
        switch operation {
        case .openLink, .reveal, .loadWishes, .changeWish:
            .organizerLinkBlocked
        case .markLinkShared, .observeGroup, .deleteGroup:
            .notOrganizer
        case .signIn, .createGroup, .recoveryPreview, .claimGroup:
            .unknown
        }
    }

    private static func notFoundError(for operation: ServiceOperation) -> ServiceError {
        switch operation {
        case .openLink, .reveal, .loadWishes, .changeWish, .recoveryPreview, .claimGroup:
            .linkNotFound
        case .markLinkShared, .observeGroup, .deleteGroup:
            .groupNotFound
        case .signIn, .createGroup:
            .unknown
        }
    }
}
