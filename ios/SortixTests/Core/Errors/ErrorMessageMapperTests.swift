import Foundation
import Testing
@testable import Sortix

struct ErrorMessageMapperTests {
    @Test(arguments: [
        (ServiceError.network, "common.error.network.message"),
        (.invalidToken, "common.invalidLink.message"),
        (.linkNotFound, "common.invalidLink.message"),
        (.wishLimitReached, "common.error.generic.message"),
        (.quotaExceeded, "common.error.generic.message"),
        (.unknown, "common.error.generic.message")
    ])
    func messageKey(error: ServiceError, expectedKey: String) {
        #expect(ErrorMessageMapper.message(for: error).key == expectedKey)
    }

    @Test func onlyNetworkAndInvalidLinkHaveATitle() {
        #expect(ErrorMessageMapper.title(for: .network)?.key == "common.error.network.title")
        #expect(ErrorMessageMapper.title(for: .linkNotFound)?.key == "common.invalidLink.title")
        #expect(ErrorMessageMapper.title(for: .invalidToken)?.key == "common.invalidLink.title")
        #expect(ErrorMessageMapper.title(for: .notOrganizer) == nil)
        #expect(ErrorMessageMapper.title(for: .unknown) == nil)
    }
}
