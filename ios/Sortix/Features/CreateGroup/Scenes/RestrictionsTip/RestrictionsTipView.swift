import UIKit

/// A white card centered on a dimmed screen: the example of a participant who cannot draw two
/// people, a title, a short explanation and "Entendido". Scrolls when the text is very large.
final class RestrictionsTipView: UIView {
    private let scrollView = UIScrollView()
    private let cardView = UIView()
    private let illustrationView = UIView()
    private let exampleCardView = UIView()
    private let giverAvatarView = AvatarView(diameter: SizeToken.avatarSmall)
    private let giverLabel = UILabel()
    private let restrictionsTitleLabel = UILabel()
    private let pillViews = [PersonPillView(), PersonPillView()]
    private let captionLabel = UILabel()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let confirmButton: PrimaryButton

    init(onConfirm: @escaping @MainActor () -> Void) {
        confirmButton = PrimaryButton(title: "", action: onConfirm)
        super.init(frame: .zero)
        setUpStyle()
        setUpLabels()
        setUpLayout()
        setUpAccessibility()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported; RestrictionsTipView is built in code.")
    }

    func setTexts(
        exampleGiver: String,
        exampleReceivers: [String],
        restrictionsTitle: String,
        caption: String,
        title: String,
        message: String,
        confirm: String
    ) {
        // Example colors follow the design: the giver in coral, the receivers in green and amber.
        giverAvatarView.configure(name: exampleGiver, colors: ColorToken.avatarColors(at: 5))
        giverLabel.text = exampleGiver
        restrictionsTitleLabel.text = restrictionsTitle
        for (index, pill) in pillViews.enumerated() where index < exampleReceivers.count {
            pill.configure(name: exampleReceivers[index], colors: ColorToken.avatarColors(at: index))
        }
        captionLabel.text = caption
        titleLabel.text = title
        messageLabel.text = message
        confirmButton.setTitle(confirm)
        illustrationView.accessibilityLabel = caption
    }

    // MARK: - Setup

    private func setUpStyle() {
        backgroundColor = ColorToken.dimming
        cardView.backgroundColor = ColorToken.surface
        cardView.layer.cornerRadius = RadiusToken.popup
        cardView.layer.cornerCurve = .continuous
        illustrationView.backgroundColor = ColorToken.background
        illustrationView.layer.cornerRadius = RadiusToken.hero
        illustrationView.layer.cornerCurve = .continuous
        exampleCardView.backgroundColor = ColorToken.surface
        exampleCardView.layer.cornerRadius = RadiusToken.banner
        exampleCardView.layer.cornerCurve = .continuous
        exampleCardView.layer.shadowColor = UIColor.black.cgColor
        exampleCardView.layer.shadowOpacity = 0.08
        exampleCardView.layer.shadowRadius = 8
        exampleCardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        scrollView.alwaysBounceVertical = false
    }

    private func setUpLabels() {
        giverLabel.font = TypographyToken.body
        giverLabel.textColor = ColorToken.textPrimary
        restrictionsTitleLabel.font = TypographyToken.sectionHeader
        restrictionsTitleLabel.textColor = ColorToken.restriction
        captionLabel.font = TypographyToken.footnote
        captionLabel.textColor = ColorToken.textSecondary
        captionLabel.textAlignment = .center
        titleLabel.font = TypographyToken.cardTitle
        titleLabel.textColor = ColorToken.textPrimary
        titleLabel.textAlignment = .center
        messageLabel.font = TypographyToken.subheadline
        messageLabel.textColor = ColorToken.textSecondary
        messageLabel.textAlignment = .center
        [giverLabel, restrictionsTitleLabel, captionLabel, titleLabel, messageLabel].forEach { label in
            label.adjustsFontForContentSizeCategory = true
            label.numberOfLines = 0
        }
    }

    private func setUpLayout() {
        setUpExampleCard()
        setUpIllustration()
        setUpCard()

        addSubviewsForAutoLayout(scrollView)
        scrollView.addSubviewsForAutoLayout(cardView)
        let content = scrollView.contentLayoutGuide
        let frame = scrollView.frameLayoutGuide
        let centered = cardView.centerYAnchor.constraint(equalTo: frame.centerYAnchor)
        centered.priority = .defaultLow
        let fillsHeight = content.heightAnchor.constraint(greaterThanOrEqualTo: frame.heightAnchor)
        NSLayoutConstraint.activate(scrollView.constraintsPinningEdges(to: safeAreaLayoutGuide) + [
            content.widthAnchor.constraint(equalTo: frame.widthAnchor),
            fillsHeight,
            centered,
            cardView.topAnchor.constraint(greaterThanOrEqualTo: content.topAnchor, constant: SpacingToken.medium),
            cardView.bottomAnchor.constraint(lessThanOrEqualTo: content.bottomAnchor, constant: -SpacingToken.medium),
            cardView.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: SpacingToken.medium),
            cardView.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -SpacingToken.medium)
        ])
    }

    private func setUpExampleCard() {
        let chevronView = UIImageView(image: IconToken.disclosure.image)
        chevronView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(textStyle: .footnote)
        chevronView.tintColor = ColorToken.textTertiary
        let nameRow = UIStackView(arrangedSubviews: [giverAvatarView, giverLabel, chevronView])
        nameRow.spacing = SpacingToken.small
        nameRow.alignment = .center

        let iconView = UIImageView(image: IconToken.restriction.image)
        iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(textStyle: .footnote, scale: .small)
        iconView.tintColor = ColorToken.restriction
        let titleRow = UIStackView(arrangedSubviews: [iconView, restrictionsTitleLabel])
        titleRow.spacing = SpacingToken.xxSmall
        titleRow.alignment = .center

        let restrictionsStack = UIStackView(arrangedSubviews: [titleRow] + pillViews)
        restrictionsStack.axis = .vertical
        restrictionsStack.alignment = .leading
        restrictionsStack.spacing = SpacingToken.xSmall - 2
        restrictionsStack.setCustomSpacing(SpacingToken.xSmall, after: titleRow)

        let stack = UIStackView(arrangedSubviews: [nameRow, restrictionsStack])
        stack.axis = .vertical
        stack.spacing = SpacingToken.xSmall
        exampleCardView.addSubviewsForAutoLayout(stack)
        let insets = NSDirectionalEdgeInsets(
            top: SpacingToken.small,
            leading: SpacingToken.medium,
            bottom: SpacingToken.small,
            trailing: SpacingToken.medium
        )
        NSLayoutConstraint.activate(stack.constraintsPinningEdges(to: exampleCardView, insets: insets) + [
            restrictionsStack.leadingAnchor.constraint(
                equalTo: stack.leadingAnchor,
                constant: SizeToken.avatarSmall + SpacingToken.small
            )
        ])
    }

    private func setUpIllustration() {
        let stack = UIStackView(arrangedSubviews: [exampleCardView, captionLabel])
        stack.axis = .vertical
        stack.spacing = SpacingToken.small
        illustrationView.addSubviewsForAutoLayout(stack)
        let insets = NSDirectionalEdgeInsets(
            top: SpacingToken.large,
            leading: SpacingToken.large,
            bottom: SpacingToken.medium,
            trailing: SpacingToken.large
        )
        NSLayoutConstraint.activate(stack.constraintsPinningEdges(to: illustrationView, insets: insets))
    }

    private func setUpCard() {
        let stack = UIStackView(arrangedSubviews: [illustrationView, titleLabel, messageLabel, confirmButton])
        stack.axis = .vertical
        stack.spacing = SpacingToken.small
        stack.setCustomSpacing(SpacingToken.large, after: illustrationView)
        stack.setCustomSpacing(SpacingToken.large, after: messageLabel)
        cardView.addSubviewsForAutoLayout(stack)
        let insets = NSDirectionalEdgeInsets(
            top: SpacingToken.large,
            leading: SpacingToken.large,
            bottom: SpacingToken.large,
            trailing: SpacingToken.large
        )
        NSLayoutConstraint.activate(stack.constraintsPinningEdges(to: cardView, insets: insets))
    }

    /// The example is read as one sentence (its caption), and focus stays inside the card.
    private func setUpAccessibility() {
        illustrationView.isAccessibilityElement = true
        illustrationView.accessibilityTraits = .image
        titleLabel.accessibilityTraits = .header
        cardView.accessibilityViewIsModal = true
        accessibilityViewIsModal = true
    }
}
