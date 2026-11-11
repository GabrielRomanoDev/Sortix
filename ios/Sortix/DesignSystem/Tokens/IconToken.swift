import UIKit

/// SF Symbols used by the app. The raw values are technical names, not user-facing text.
enum IconToken: String, CaseIterable {
    case add = "plus"
    case gift = "gift"
    case draft = "pencil"
    case participating = "person.2"
    case disclosure = "chevron.right"
    case contacts = "person.crop.circle"
    case remove = "xmark"
    case success = "checkmark.circle"
    case locked = "lock"
    case draw = "shuffle"
    case about = "info.circle"
    case share = "square.and.arrow.up"
    case externalLink = "arrow.up.right"
    case networkError = "wifi.exclamationmark"
    case genericError = "exclamationmark.triangle"

    /// The symbol image, or `nil` if the symbol does not exist on the running iOS version.
    var image: UIImage? {
        UIImage(systemName: rawValue)
    }

    /// The symbol image rendered with a configuration, such as a scaled text style.
    func image(with configuration: UIImage.SymbolConfiguration) -> UIImage? {
        UIImage(systemName: rawValue, withConfiguration: configuration)
    }
}
