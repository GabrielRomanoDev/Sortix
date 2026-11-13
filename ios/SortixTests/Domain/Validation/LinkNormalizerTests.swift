import Testing
@testable import Sortix

struct LinkNormalizerTests {
    @Test(arguments: [
        ("loja.com/x", "https://loja.com/x"),
        ("http://loja.com", "http://loja.com"),
        ("https://loja.com/produto?id=1", "https://loja.com/produto?id=1"),
        ("  loja.com  ", "https://loja.com"),
        ("loja.com:8080/x", "https://loja.com:8080/x")
    ])
    func acceptsWebLinks(input: String, expected: String) {
        #expect(LinkNormalizer.normalize(input) == expected)
    }

    @Test(arguments: ["javascript:alert(1)", "ftp://loja.com", "mailto:ana@loja.com", "https://", "", "   "])
    func rejectsOtherLinks(input: String) {
        #expect(LinkNormalizer.normalize(input) == nil)
    }
}
