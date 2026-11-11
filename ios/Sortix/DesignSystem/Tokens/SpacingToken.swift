import CoreGraphics

/// Spacing scale for margins, paddings and gaps between views.
enum SpacingToken {
    static let xxSmall: CGFloat = 4
    static let xSmall: CGFloat = 8
    static let small: CGFloat = 12
    static let medium: CGFloat = 16
    static let large: CGFloat = 24
    static let xLarge: CGFloat = 32

    /// Horizontal margin between full-width content and the screen edges.
    static let screenMargin: CGFloat = 20
}
