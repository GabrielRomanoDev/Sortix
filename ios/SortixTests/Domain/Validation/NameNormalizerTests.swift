import Testing
@testable import Sortix

struct NameNormalizerTests {
    @Test func matchesSharedVectors() throws {
        for vector in try TestVectors.normalization().normalization {
            #expect(NameNormalizer.normalize(vector.input) == vector.expected, "Input: \(vector.input)")
        }
    }

    @Test func countsCharactersAsPeopleSeeThem() throws {
        for vector in try TestVectors.normalization().graphemeCount {
            #expect(vector.input.count == vector.expected, "Input: \(vector.input)")
        }
    }
}
