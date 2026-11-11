import CoreGraphics

/// Corner radii. Apply them with `cornerCurve = .continuous` to match system shapes.
enum RadiusToken {
    /// Small tags, such as the selected date chip.
    static let tag: CGFloat = 8
    /// Text fields and grouped form containers.
    static let field: CGFloat = 12
    /// Inline notices, such as the draw feasibility and privacy banners.
    static let banner: CGFloat = 14
    /// Cards, list tiles and icon tiles.
    static let card: CGFloat = 16
    /// Primary and secondary buttons.
    static let button: CGFloat = 16
    /// Large call-to-action panels, such as "reveal who you drew".
    static let hero: CGFloat = 22
    /// Bottom corners of the reveal header.
    static let revealHeader: CGFloat = 28
}
