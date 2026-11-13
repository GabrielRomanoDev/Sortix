/// Reads what the person types in a money field. Digits fill the cents from right to left:
/// "5" is R$ 0,05 and "5000" is R$ 50,00. Anything that is not a digit is ignored.
enum CurrencyInputParser {
    /// Digits kept at most. Enough for any valid amount and far from `Int` overflow; the validator
    /// reports amounts above the limit.
    static let maxDigits = 12

    /// Returns the amount in cents, or `nil` when the text has no digits.
    static func amountMinor(from text: String) -> Int? {
        let digits = text.filter(\.isASCII).filter(\.isNumber).prefix(maxDigits)
        return Int(String(digits))
    }
}
