import Testing
@testable import Sortix

struct StringTrimmingTests {
    @Test(arguments: [
        ("  Ana  ", "Ana"),
        ("\n\tBruno\n", "Bruno"),
        ("Carla Souza", "Carla Souza"),
        ("   ", "")
    ])
    func trimmedRemovesLeadingAndTrailingWhitespace(input: String, expected: String) {
        #expect(input.trimmed == expected)
    }

    @Test(arguments: ["", " ", "\n\t "])
    func isBlankIsTrueForWhitespaceOnly(input: String) {
        #expect(input.isBlank)
    }

    @Test func isBlankIsFalseWhenThereIsText() {
        #expect(!" Diego ".isBlank)
    }
}
