import Foundation

/// Turns typed errors into texts from the String Catalog. ViewControllers use it; ViewModels keep
/// the typed error in their state.
///
/// The switches have no `default`, so a new error case does not compile until it gets a message.
enum ErrorMessageMapper {
    // TODO(error-messages): give organizer, group and suggestion errors their own messages when
    // their screens land. Until then they use the generic message (section 6.7).
    static func message(for error: ServiceError) -> LocalizedStringResource {
        switch error {
        case .network:
            .commonErrorNetworkMessage
        case .invalidToken, .linkNotFound:
            .commonInvalidLinkMessage
        case .unauthenticated, .organizerLinkBlocked, .notOrganizer, .groupNotFound,
             .wishLimitReached, .wishNotFound, .quotaExceeded, .unknown:
            .commonErrorGenericMessage
        }
    }

    /// Title for errors that have one, such as "Sem conexão". Other errors show only the message.
    static func title(for error: ServiceError) -> LocalizedStringResource? {
        switch error {
        case .network:
            .commonErrorNetworkTitle
        case .invalidToken, .linkNotFound:
            .commonInvalidLinkTitle
        case .unauthenticated, .organizerLinkBlocked, .notOrganizer, .groupNotFound,
             .wishLimitReached, .wishNotFound, .quotaExceeded, .unknown:
            nil
        }
    }
}
