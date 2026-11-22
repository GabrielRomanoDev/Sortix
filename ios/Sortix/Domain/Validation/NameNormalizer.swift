import Foundation

/// Normalizes participant names to compare them (BR-10): "Ana", " ana " and "Aná" are the same.
///
/// Must give the same result as `normalization.ts`. The cases in `shared/test-vectors/normalization.json`
/// are repeated in `NameNormalizerTests`.
enum NameNormalizer {
    static func normalize(_ name: String) -> String {
        let words = name.split(whereSeparator: \.isWhitespace)
        let collapsed = words.joined(separator: " ")
        return collapsed.folding(
            options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive],
            locale: nil
        )
    }
}
