import Foundation
import Testing
@testable import Sortix

struct WebPageTests {
    @Test func urls() {
        #expect(WebPage.privacy.url.absoluteString == "https://sortixamigosecreto.com.br/privacidade")
        #expect(WebPage.support.url.absoluteString == "https://sortixamigosecreto.com.br/suporte")
    }
}
