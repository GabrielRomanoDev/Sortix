import UIKit

/// A row with a title and a `UISwitch`, for `FormSectionView`.
@MainActor
final class ToggleRow: UIView {
    let toggle = UISwitch()

    /// Called when the person flips the switch.
    var onToggle: ((Bool) -> Void)?

    private let titleLabel = UILabel()

    /// - Parameter title: Visible label from the String Catalog. Also used as the accessibility label.
    init(title: String) {
        super.init(frame: .zero)
        setUpTitle()
        setUpToggle()
        setTexts(title: title)
        setUpLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported; ToggleRow is built in code.")
    }

    /// Shows the given value. Does not call `onToggle`.
    func configure(isOn: Bool) {
        if toggle.isOn != isOn {
            toggle.setOn(isOn, animated: false)
        }
    }

    // MARK: - Texts

    private func setTexts(title: String) {
        titleLabel.text = title
        toggle.accessibilityLabel = title
    }

    // MARK: - Setup

    private func setUpTitle() {
        titleLabel.font = TypographyToken.body
        titleLabel.textColor = ColorToken.textPrimary
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.numberOfLines = 0
        titleLabel.isAccessibilityElement = false
    }

    private func setUpToggle() {
        toggle.onTintColor = ColorToken.accent
        toggle.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            onToggle?(toggle.isOn)
        }, for: .valueChanged)
    }

    private func setUpLayout() {
        toggle.setContentHuggingPriority(.required, for: .horizontal)
        let stack = UIStackView(arrangedSubviews: [titleLabel, toggle])
        stack.spacing = SpacingToken.small
        stack.alignment = .center
        addSubviewsForAutoLayout(stack)

        let insets = NSDirectionalEdgeInsets(
            top: SpacingToken.small,
            leading: SpacingToken.medium,
            bottom: SpacingToken.small,
            trailing: SpacingToken.medium
        )
        NSLayoutConstraint.activate(stack.constraintsPinningEdges(to: self, insets: insets) + [
            heightAnchor.constraint(greaterThanOrEqualToConstant: SizeToken.rowMinHeight)
        ])
    }
}
