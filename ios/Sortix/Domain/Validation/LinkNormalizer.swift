import Foundation

/// Turns a typed link into a valid `http` or `https` address (BR-39).
enum LinkNormalizer {
    /// Returns the normalized link, or `nil` when it is not a valid web address.
    ///
    /// A link without a scheme ("loja.com/x") gets `https://`. Any scheme other than `http` and
    /// `https` (`javascript:`, `mailto:`, `ftp:`) is rejected.
    static func normalize(_ text: String) -> String? {
        let trimmed = text.trimmed
        guard !trimmed.isEmpty else { return nil }

        let link = hasScheme(trimmed) ? trimmed : "https://" + trimmed
        guard
            let components = URLComponents(string: link),
            let scheme = components.scheme?.lowercased(),
            scheme == "http" || scheme == "https",
            let host = components.host,
            !host.isEmpty
        else { return nil }
        return link
    }

    /// Whether the text starts with a scheme such as "https:" or "mailto:". A colon that comes
    /// after a dot or a slash ("loja.com:8080") is a port, not a scheme.
    private static func hasScheme(_ text: String) -> Bool {
        guard let colonIndex = text.firstIndex(of: ":") else { return false }
        let prefix = text[..<colonIndex]
        return !prefix.isEmpty && prefix.allSatisfy { $0.isLetter || $0.isNumber || $0 == "+" || $0 == "-" }
    }
}
