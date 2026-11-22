import Testing
@testable import Sortix

struct ServiceErrorTests {
    private struct OtherError: Error {}

    @Test func keepsAServiceError() {
        #expect(ServiceError(ServiceError.wishLimitReached) == .wishLimitReached)
    }

    @Test func treatsOtherErrorsAsUnknown() {
        #expect(ServiceError(OtherError()) == .unknown)
    }

    @Test(arguments: [
        (ServiceError.invalidToken, "INVALID_TOKEN"),
        (.linkNotFound, "LINK_NOT_FOUND"),
        (.organizerLinkBlocked, "ORGANIZER_LINK_BLOCKED"),
        (.groupNotFound, "GROUP_NOT_FOUND"),
        (.notOrganizer, "NOT_ORGANIZER"),
        (.wishLimitReached, "WISH_LIMIT_REACHED"),
        (.wishNotFound, "WISH_NOT_FOUND"),
        (.network, "NETWORK"),
        (.quotaExceeded, "QUOTA_EXCEEDED"),
        (.unknown, "UNKNOWN")
    ])
    func reasonMatchesTheSharedCode(error: ServiceError, code: String) {
        #expect(error.reason.rawValue == code)
    }
}
