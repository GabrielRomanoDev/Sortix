import UIKit

/// Holds the main button of a screen at the bottom, with the screen margins around it. Place it
/// last in the screen and pin its bottom to `keyboardLayoutGuide.topAnchor`.
@MainActor
final class FooterActionView: UIView {
    init(button: UIButton) {
        super.init(frame: .zero)
        backgroundColor = ColorToken.background
        // Keeps its own height in a vertical stack; the list or scroll view takes the rest.
        setContentHuggingPriority(.required, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .vertical)
        addSubviewsForAutoLayout(button)
        let insets = NSDirectionalEdgeInsets(
            top: SpacingToken.xSmall,
            leading: SpacingToken.screenMargin,
            bottom: SpacingToken.xSmall,
            trailing: SpacingToken.screenMargin
        )
        NSLayoutConstraint.activate(button.constraintsPinningEdges(to: self, insets: insets))
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported; FooterActionView is built in code.")
    }
}
