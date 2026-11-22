import Testing
@testable import Sortix

/// Same cases as `shared/test-vectors/normalization.json`, written here so the tests also run on a
/// physical device, which cannot read files from the Mac.
struct NameNormalizerTests {
    @Test(arguments: [
        ("  Ana  ", "ana"),
        ("Aná", "ana"),
        ("JOÃO   Pedro", "joao pedro"),
        ("Ｍａｒｉａ", "maria"),
        ("Mãe", "mae")
    ])
    func normalizesNames(input: String, expected: String) {
        #expect(NameNormalizer.normalize(input) == expected)
    }

    @Test(arguments: [
        ("Mãe", 3),
        ("👩‍👩‍👧", 1),
        ("Zoë 🎄", 5)
    ])
    func countsCharactersAsPeopleSeeThem(input: String, expected: Int) {
        #expect(input.count == expected)
    }
}
