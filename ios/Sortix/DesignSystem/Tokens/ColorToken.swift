import UIKit

/// Semantic colors of the app. Screens and components use these names, never raw values.
///
/// Brand colors live in the Asset Catalog with light and dark variants and are read through the
/// generated `ColorResource` symbols. Every text and background pair keeps a contrast ratio of at
/// least 4.5:1 in both appearances (values and ratios in section 6.9 of the specification).
@MainActor
enum ColorToken {
    // MARK: - Brand

    /// Primary actions, links, selection and progress.
    static var accent: UIColor { UIColor(resource: .accent) }

    /// Text and icons placed on `accent`: white in light mode, black in dark mode.
    static var onAccent: UIColor { UIColor(resource: .onAccent) }

    /// Supporting text placed on `accent`, such as the subtitle of the reveal header.
    static var onAccentSecondary: UIColor { UIColor(resource: .onAccentSecondary) }

    /// Tinted background for positive banners, badges and icon tiles; pair it with `accent`.
    static var accentSoft: UIColor { UIColor(resource: .accentSoft) }

    // MARK: - Surfaces

    /// Screen background behind grouped content.
    static var background: UIColor { .systemGroupedBackground }

    /// Cards, grouped rows and fields placed on `background`.
    static var surface: UIColor { .secondarySystemGroupedBackground }

    /// Hairlines between rows of a grouped container.
    static var separator: UIColor { .separator }

    /// Inactive progress segments and other neutral fills.
    static var inactive: UIColor { .systemGray4 }

    // MARK: - Text

    static var textPrimary: UIColor { .label }

    /// Secondary text. Darker than `secondaryLabel` so small text stays above 4.5:1.
    static var textSecondary: UIColor { UIColor(resource: .textSecondary) }

    /// Disclosure chevrons and other decorative glyphs that carry no information on their own.
    static var textTertiary: UIColor { .tertiaryLabel }

    // MARK: - Status

    /// Text and icons of cautionary notices; pair it with `warningSoft`.
    static var warning: UIColor { UIColor(resource: .warning) }

    /// Tinted background of cautionary notices and of the reveal call to action.
    static var warningSoft: UIColor { UIColor(resource: .warningSoft) }

    static var destructive: UIColor { .systemRed }

    // MARK: - Avatars

    /// Background and foreground pairs used for participant initials, in display order.
    static var avatarPalette: [AvatarColors] {
        [
            AvatarColors(background: UIColor(resource: .avatarGreenBackground),
                         foreground: UIColor(resource: .avatarGreenForeground)),
            AvatarColors(background: UIColor(resource: .avatarAmberBackground),
                         foreground: UIColor(resource: .avatarAmberForeground)),
            AvatarColors(background: UIColor(resource: .avatarBlueBackground),
                         foreground: UIColor(resource: .avatarBlueForeground)),
            AvatarColors(background: UIColor(resource: .avatarPinkBackground),
                         foreground: UIColor(resource: .avatarPinkForeground)),
            AvatarColors(background: UIColor(resource: .avatarPurpleBackground),
                         foreground: UIColor(resource: .avatarPurpleForeground)),
            AvatarColors(background: UIColor(resource: .avatarCoralBackground),
                         foreground: UIColor(resource: .avatarCoralForeground))
        ]
    }

    /// Returns the avatar colors for a position in a list, cycling through `avatarPalette`.
    static func avatarColors(at index: Int) -> AvatarColors {
        let palette = avatarPalette
        let wrappedIndex = ((index % palette.count) + palette.count) % palette.count
        return palette[wrappedIndex]
    }
}

extension ColorToken {
    /// Colors of a participant's initials badge.
    nonisolated struct AvatarColors: Equatable, Sendable {
        let background: UIColor
        let foreground: UIColor
    }
}
