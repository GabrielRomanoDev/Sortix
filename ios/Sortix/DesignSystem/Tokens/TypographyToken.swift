import UIKit

/// Text styles of the app. Every font scales with Dynamic Type through `UIFontMetrics`, so labels
/// with `adjustsFontForContentSizeCategory = true` follow the user's text size.
@MainActor
enum TypographyToken {
    /// 34 pt bold. Title of the group list.
    static var largeTitle: UIFont { scaled(34, .bold, .largeTitle) }
    /// 28 pt bold. Titles of the other screens and of empty and success states.
    static var title: UIFont { scaled(28, .bold, .title1) }
    /// 20 pt bold. Title inside a summary card.
    static var cardTitle: UIFont { scaled(20, .bold, .title3) }
    /// 17 pt semibold. Row titles, emphasized values and button titles.
    static var headline: UIFont { scaled(17, .semibold, .headline) }
    /// 17 pt regular. Default text, fields and row labels.
    static var body: UIFont { scaled(17, .regular, .body) }
    /// 16 pt regular. Compact row labels and secondary buttons.
    static var callout: UIFont { scaled(16, .regular, .callout) }
    /// 15 pt regular. Subtitles, banners and supporting paragraphs.
    static var subheadline: UIFont { scaled(15, .regular, .subheadline) }
    /// 13 pt regular. Row subtitles, footers and counters.
    static var footnote: UIFont { scaled(13, .regular, .footnote) }
    /// 13 pt semibold. Section headers, displayed in uppercase by the caller.
    static var sectionHeader: UIFont { scaled(13, .semibold, .footnote) }
    /// 12 pt semibold. Status badges.
    static var caption: UIFont { scaled(12, .semibold, .caption1) }
    /// 48 pt heavy. Name of the drawn person on the reveal screen.
    static var revealName: UIFont { scaled(48, .heavy, .largeTitle) }

    private static func scaled(_ size: CGFloat, _ weight: UIFont.Weight, _ style: UIFont.TextStyle) -> UIFont {
        UIFontMetrics(forTextStyle: style).scaledFont(for: .systemFont(ofSize: size, weight: weight))
    }
}
