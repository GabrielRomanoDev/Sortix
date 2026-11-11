import UIKit

/// Text styles of the app, all scaled with Dynamic Type.
///
/// Each style starts from the size of a system text style at the default content size and is scaled
/// with `UIFontMetrics` for that same text style, so labels with
/// `adjustsFontForContentSizeCategory = true` follow the user's text size.
@MainActor
enum TypographyToken {
    enum Style: CaseIterable {
        /// 34 pt bold. Title of the group list.
        case largeTitle
        /// 28 pt bold. Titles of the other screens and of empty and success states.
        case title
        /// 20 pt bold. Title inside a summary card.
        case cardTitle
        /// 17 pt semibold. Row titles, emphasized values and button titles.
        case headline
        /// 17 pt regular. Default text, fields and row labels.
        case body
        /// 16 pt regular. Compact row labels and secondary buttons.
        case callout
        /// 15 pt regular. Subtitles, banners and supporting paragraphs.
        case subheadline
        /// 13 pt regular. Row subtitles, footers and counters.
        case footnote
        /// 13 pt semibold. Section headers, displayed in uppercase by the caller.
        case sectionHeader
        /// 12 pt semibold. Status badges.
        case caption
        /// 48 pt heavy. Name of the drawn person on the reveal screen.
        case revealName
    }

    private static let revealNameSize: CGFloat = 48

    static func font(for style: Style) -> UIFont {
        switch style {
        case .largeTitle: scaledFont(.largeTitle, weight: .bold)
        case .title: scaledFont(.title1, weight: .bold)
        case .cardTitle: scaledFont(.title3, weight: .bold)
        case .headline: scaledFont(.headline, weight: .semibold)
        case .body: scaledFont(.body, weight: .regular)
        case .callout: scaledFont(.callout, weight: .regular)
        case .subheadline: scaledFont(.subheadline, weight: .regular)
        case .footnote: scaledFont(.footnote, weight: .regular)
        case .sectionHeader: scaledFont(.footnote, weight: .semibold)
        case .caption: scaledFont(.caption1, weight: .semibold)
        case .revealName: scaledFont(.largeTitle, weight: .heavy, size: revealNameSize)
        }
    }

    private static func scaledFont(
        _ textStyle: UIFont.TextStyle,
        weight: UIFont.Weight,
        size: CGFloat? = nil
    ) -> UIFont {
        let defaultTraits = UITraitCollection(preferredContentSizeCategory: .large)
        let defaultSize = UIFontDescriptor
            .preferredFontDescriptor(withTextStyle: textStyle, compatibleWith: defaultTraits)
            .pointSize
        let font = UIFont.systemFont(ofSize: size ?? defaultSize, weight: weight)
        return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: font)
    }
}
