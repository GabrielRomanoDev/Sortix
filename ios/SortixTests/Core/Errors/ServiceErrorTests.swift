import Testing
@testable import Sortix

struct ServiceErrorTests {
    private struct OtherError: Error {}

    @Test func keepsAServiceError() {
        let error = ServiceError.rejected(.invalidWish, field: "link")

        #expect(ServiceError(error) == .rejected(.invalidWish, field: "link"))
    }

    @Test func treatsOtherErrorsAsUnknown() {
        #expect(ServiceError(OtherError()) == .unknown)
    }

    @Test func reasonReadsTheServerCode() {
        #expect(FunctionErrorReason(rawValue: "WISH_LIMIT_REACHED") == .wishLimitReached)
        #expect(FunctionErrorReason(rawValue: "SOMETHING_NEW") == nil)
    }
}
