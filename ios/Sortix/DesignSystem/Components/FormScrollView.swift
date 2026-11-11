import UIKit

/// Scrollable vertical stack for screens with a fixed set of fields.
///
/// Fields stay alive while the person scrolls, which avoids the cell reuse problems a list would
/// have with text being edited. Pin the bottom of this view to `view.keyboardLayoutGuide.topAnchor`
/// (or to the top of a pinned `PrimaryButton`) so the focused field is never hidden by the keyboard.
@MainActor
final class FormScrollView: UIScrollView {
    private let contentStack = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = ColorToken.background
        alwaysBounceVertical = true
        keyboardDismissMode = .interactive
        setUpContentStack()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported; FormScrollView is built in code.")
    }

    /// Appends a section, or any other view, at the end of the form.
    func addArrangedSubview(_ view: UIView) {
        contentStack.addArrangedSubview(view)
    }

    /// Scrolls so that `view`, a descendant of the form, becomes visible.
    func scrollToVisible(_ view: UIView, animated: Bool) {
        let rect = view.convert(view.bounds, to: self)
        scrollRectToVisible(rect.insetBy(dx: 0, dy: -SpacingToken.medium), animated: animated)
    }

    private func setUpContentStack() {
        contentStack.axis = .vertical
        contentStack.spacing = SpacingToken.large
        addSubviewsForAutoLayout(contentStack)

        let margins = NSDirectionalEdgeInsets(
            top: SpacingToken.large,
            leading: SpacingToken.screenMargin,
            bottom: SpacingToken.large,
            trailing: SpacingToken.screenMargin
        )
        NSLayoutConstraint.activate(
            contentStack.constraintsPinningEdges(to: contentLayoutGuide, insets: margins) + [
                contentStack.widthAnchor.constraint(
                    equalTo: frameLayoutGuide.widthAnchor,
                    constant: -(margins.leading + margins.trailing)
                )
            ]
        )
    }
}
