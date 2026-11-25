import UIKit

/// Holds the main button of a screen at the bottom, with the screen margins around it. Place it
/// last in the screen and pin its bottom to `keyboardLayoutGuide.topAnchor`.
@MainActor
final class FooterActionView: UIView {
    init(button: UIButton) {
        super.init(frame: .zero)
        backgroundColor = ColorToken.background
        // Hugging has no effect on a view without an intrinsic size, so a weak zero height keeps this
        // view as short as its content allows; the list or state view next to it takes the rest.
        let compactHeight = heightAnchor.constraint(equalToConstant: 0)
        compactHeight.priority = .fittingSizeLevel
        compactHeight.isActive = true
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
