import Foundation

/// Pages of the website the app opens in Safari (section 5.11).
///
/// The paths are public, user-facing URLs and stay in pt-BR.
enum WebPage: Equatable, Sendable {
    case privacy
    case support

    var url: URL {
        guard let url = URL(string: "https://sortixamigosecreto.com.br\(path)") else {
            preconditionFailure("The website URL is built from fixed strings and must be valid.")
        }
        return url
    }

    private var path: String {
        switch self {
        case .privacy: "/privacidade"
        case .support: "/suporte"
        }
    }
}
