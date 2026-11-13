import Foundation
import Testing
@testable import Sortix

/// Plural keys must be checked with 0, 1 and 2, because plural categories change between languages.
/// In pt-BR, 0 falls in the "one" category, like 1.
struct LocalizationTests {
    @Test(arguments: [
        (0, "Use no máximo 0 caractere."),
        (1, "Use no máximo 1 caractere."),
        (2, "Use no máximo 2 caracteres.")
    ])
    func tooLongUsesThePluralVariation(limit: Int, expected: String) {
        var resource = LocalizedStringResource.validationTooLong(limit)
        resource.locale = Locale(identifier: "pt_BR")

        #expect(String(localized: resource) == expected)
    }
}
