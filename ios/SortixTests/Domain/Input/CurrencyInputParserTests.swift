import Testing
@testable import Sortix

struct CurrencyInputParserTests {
    @Test(arguments: [
        ("5", 5),
        ("5000", 5_000),
        ("R$ 50,00", 5_000),
        ("0005", 5),
        ("1.234,56", 123_456)
    ])
    func digitsBecomeCents(text: String, expected: Int) {
        #expect(CurrencyInputParser.amountMinor(from: text) == expected)
    }

    @Test func textWithoutDigitsHasNoAmount() {
        #expect(CurrencyInputParser.amountMinor(from: "") == nil)
        #expect(CurrencyInputParser.amountMinor(from: "R$ ,") == nil)
    }

    @Test func keepsAtMostTwelveDigits() {
        #expect(CurrencyInputParser.amountMinor(from: "1234567890123") == 123_456_789_012)
    }
}
