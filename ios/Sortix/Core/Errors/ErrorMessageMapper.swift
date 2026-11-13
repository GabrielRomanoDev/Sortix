import Foundation

/// Turns typed errors into texts from the String Catalog. ViewControllers use it; ViewModels keep
/// the typed error in their state.
///
/// The switches have no `default`, so a new error case does not compile until it gets a message.
enum ErrorMessageMapper {
    static func message(for error: ServiceError) -> LocalizedStringResource {
        switch error {
        case .network:
            .commonErrorNetworkMessage
        case .linkNotFound:
            .commonInvalidLinkMessage
        case .rejected(let reason, _):
            message(for: reason)
        case .unauthenticated, .permissionDenied, .unknown:
            .commonErrorGenericMessage
        }
    }

    /// Title for errors that have one, such as "Sem conexão". Other errors show only the message.
    static func title(for error: ServiceError) -> LocalizedStringResource? {
        switch error {
        case .network:
            .commonErrorNetworkTitle
        case .linkNotFound:
            .commonInvalidLinkTitle
        case .rejected(.linkNotFound, _), .rejected(.invalidToken, _):
            .commonInvalidLinkTitle
        case .rejected, .unauthenticated, .permissionDenied, .unknown:
            nil
        }
    }

    // TODO(error-messages): give form and suggestion reasons their own messages when their screens land.
    private static func message(for reason: FunctionErrorReason) -> LocalizedStringResource {
        switch reason {
        case .linkNotFound, .invalidToken:
            .commonInvalidLinkMessage
        case .invalidRequest, .invalidGroupName, .invalidRules, .invalidParticipants,
             .invalidParticipantName, .duplicatedParticipantName, .invalidRestriction,
             .invalidAssignment, .groupIDConflict, .notOrganizer, .groupNotFound,
             .invalidWish, .wishLimitReached, .wishNotFound:
            .commonErrorGenericMessage
        }
    }
}
