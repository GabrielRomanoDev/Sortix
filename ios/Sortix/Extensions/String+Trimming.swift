import Foundation

extension String {
    /// The string without leading and trailing whitespace and newlines.
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Whether the string has no characters other than whitespace and newlines.
    var isBlank: Bool {
        trimmed.isEmpty
    }
}
