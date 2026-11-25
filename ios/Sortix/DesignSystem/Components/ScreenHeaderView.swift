import UIKit

/// The top of a screen, below a plain navigation bar: a bold title, an optional subtitle, an
/// optional view on the trailing side (such as a round add button) and, in the creation flow,
/// the step progress bar.
@MainActor
final class ScreenHeaderView: UIView {
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let accessoryView: UIView?
    private let progressView: StepProgressView?

    /// - Parameters:
    ///   - titleFont: `TypographyToken.largeTitle` on the group list, `title` elsewhere.
    ///   - step: The current step and the number of steps, for screens of the creation flow.
    ///   - accessoryView: Shown on the trailing side, centered on the title.
    init(
        titleFont: UIFont = TypographyToken.title,
        step: (current: Int, total: Int)? = nil,
        accessoryView: UIView? = nil
    ) {
        self.accessoryView = accessoryView
        progressView = step.map { StepProgressView(current: $0.current, total: $0.total) }
        super.init(frame: .zero)
        setUpLabels(titleFont: titleFont)
        setUpLayout()
        // Hugging has no effect on a view without an intrinsic size, so a weak zero height keeps this
        // view as short as its content allows; the list or state view next to it takes the rest.
        let compactHeight = heightAnchor.constraint(equalToConstant: 0)
        compactHeight.priority = .fittingSizeLevel
        compactHeight.isActive = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported; ScreenHeaderView is built in code.")
    }

    func setTexts(title: String, subtitle: String? = nil) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        subtitleLabel.isHidden = subtitle == nil
    }

    private func setUpLabels(titleFont: UIFont) {
        titleLabel.font = titleFont
        titleLabel.textColor = ColorToken.textPrimary
        titleLabel.accessibilityTraits = .header

        subtitleLabel.font = TypographyToken.subheadline
        subtitleLabel.textColor = ColorToken.textSecondary
        subtitleLabel.isHidden = true

        [titleLabel, subtitleLabel].forEach { label in
            label.adjustsFontForContentSizeCategory = true
            label.numberOfLines = 0
        }
    }

    private func setUpLayout() {
        let labelsStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        labelsStack.axis = .vertical
        labelsStack.spacing = SpacingToken.xxSmall

        let titleRow = UIStackView(arrangedSubviews: [labelsStack] + [accessoryView].compactMap { $0 })
        titleRow.spacing = SpacingToken.small
        titleRow.alignment = .center

        let stack = UIStackView(arrangedSubviews: [titleRow] + [progressView].compactMap { $0 })
        stack.axis = .vertical
        stack.spacing = SpacingToken.small
        addSubviewsForAutoLayout(stack)

        let insets = NSDirectionalEdgeInsets(
            top: SpacingToken.xSmall,
            leading: SpacingToken.screenMargin,
            bottom: SpacingToken.small,
            trailing: SpacingToken.screenMargin
        )
        NSLayoutConstraint.activate(stack.constraintsPinningEdges(to: self, insets: insets))
    }
}
