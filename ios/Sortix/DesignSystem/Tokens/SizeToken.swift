import CoreGraphics

/// Fixed dimensions of controls and decorations.
///
/// Heights of views that contain text are minimums: use them in `greaterThanOrEqualTo`
/// constraints so the view can grow with Dynamic Type.
enum SizeToken {
    /// Minimum width and height of anything tappable (Human Interface Guidelines).
    static let minimumTouchTarget: CGFloat = 44
    /// Minimum height of `PrimaryButton`.
    static let primaryButtonMinHeight: CGFloat = 54
    /// Minimum height of form rows and text fields.
    static let rowMinHeight: CGFloat = 50
    /// Diameter of the initials badge in compact lists.
    static let avatarSmall: CGFloat = 32
    /// Diameter of the initials badge in the group status list.
    static let avatarMedium: CGFloat = 36
    /// Side of the rounded square that holds a group's icon.
    static let iconTile: CGFloat = 48
    /// Diameter of the circle behind the icon of a success header.
    static let heroIcon: CGFloat = 72
    /// Height of each segment of the creation flow progress bar.
    static let progressBarHeight: CGFloat = 4
}
