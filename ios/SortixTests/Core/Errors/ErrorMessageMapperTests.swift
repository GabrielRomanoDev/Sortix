import Foundation
import Testing
@testable import Sortix

struct ErrorMessageMapperTests {
    @Test(arguments: [
        (ServiceError.network, "common.error.network.message"),
        (.linkNotFound, "common.invalidLink.message"),
        (.rejected(.invalidToken, field: nil), "common.invalidLink.message"),
        (.rejected(.wishLimitReached, field: nil), "common.error.generic.message"),
        (.unknown, "common.error.generic.message")
    ])
    func messageKey(error: ServiceError, expectedKey: String) {
        #expect(ErrorMessageMapper.message(for: error).key == expectedKey)
    }

    @Test func onlyNetworkAndInvalidLinkHaveATitle() {
        #expect(ErrorMessageMapper.title(for: .network)?.key == "common.error.network.title")
        #expect(ErrorMessageMapper.title(for: .linkNotFound)?.key == "common.invalidLink.title")
        #expect(ErrorMessageMapper.title(for: .unknown) == nil)
    }
}
