import UIKit

/// One participant as a card of its own: avatar, name, "Você" for the organizer and a chevron, then
/// who this person cannot draw as pills stacked below the name.
///
/// The padding around the content is fixed, so the card grows with each restriction and keeps the
/// same space below the last one.
final class ParticipantCardCell: UICollectionViewListCell {
    private let avatarView = AvatarView(diameter: SizeToken.avatarSmall)
    private let nameLabel = UILabel()
    private let tagLabel = UILabel()
    private let chevronView = UIImageView(image: IconToken.disclosure.image)
    private let errorLabel = InlineErrorLabel()
    private let restrictionsTitleLabel = UILabel()
    private let restrictionsIconView = UIImageView(image: IconToken.restriction.image)
    private let pillsStack = UIStackView()
    private let restrictionsStack = UIStackView()
    private let detailsWrapper = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpLabels()
        setUpImages()
        setUpLayout()
        isAccessibilityElement = true
        accessibilityTraits = .button
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported; ParticipantCardCell is built in code.")
    }

    /// - Parameters:
    ///   - name: The participant's name, or a hint when the organizer has not typed theirs.
    ///   - isPlaceholder: Shows `name` in the secondary color.
    ///   - tag: "Você" for the organizer.
    ///   - colors: The avatar colors of this participant.
    ///   - restrictionsTitle: "Não pode tirar".
    ///   - forbiddenReceivers: Who this participant cannot draw, with their avatar colors.
    func configure(
        name: String,
        isPlaceholder: Bool,
        tag: String?,
        colors: ColorToken.AvatarColors,
        restrictionsTitle: String,
        forbiddenReceivers: [(name: String, colors: ColorToken.AvatarColors)],
        errorMessage: String?
    ) {
        avatarView.configure(name: isPlaceholder ? "" : name, colors: colors)
        nameLabel.text = name
        nameLabel.textColor = isPlaceholder ? ColorToken.textSecondary : ColorToken.textPrimary
        tagLabel.text = tag
        tagLabel.isHidden = tag == nil
        errorLabel.message = errorMessage
        restrictionsTitleLabel.text = restrictionsTitle
        setPills(forbiddenReceivers)
        detailsWrapper.isHidden = errorMessage == nil && forbiddenReceivers.isEmpty
        accessibilityLabel = makeAccessibilityLabel(
            name: name,
            tag: tag,
            restrictionsTitle: restrictionsTitle,
            receiverNames: forbiddenReceivers.map(\.name),
            errorMessage: errorMessage
        )
        invalidateIntrinsicContentSize()
    }

    // MARK: - Content

    private func setPills(_ receivers: [(name: String, colors: ColorToken.AvatarColors)]) {
        pillsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for receiver in receivers {
            let pill = PersonPillView()
            pill.configure(name: receiver.name, colors: receiver.colors)
            pillsStack.addArrangedSubview(pill)
        }
        restrictionsStack.isHidden = receivers.isEmpty
    }

    private func makeAccessibilityLabel(
        name: String,
        tag: String?,
        restrictionsTitle: String,
        receiverNames: [String],
        errorMessage: String?
    ) -> String {
        var parts = [name]
        if let tag {
            parts.append(tag)
        }
        if !receiverNames.isEmpty {
            parts.append(restrictionsTitle + ": " + receiverNames.formatted(.list(type: .and)))
        }
        if let errorMessage {
            parts.append(errorMessage)
        }
        return parts.joined(separator: ", ")
    }

    // MARK: - Setup

    private func setUpLabels() {
        nameLabel.font = TypographyToken.body
        tagLabel.font = TypographyToken.footnote
        tagLabel.textColor = ColorToken.textSecondary
        restrictionsTitleLabel.font = TypographyToken.sectionHeader
        restrictionsTitleLabel.textColor = ColorToken.restriction
        [nameLabel, tagLabel, restrictionsTitleLabel].forEach { label in
            label.adjustsFontForContentSizeCategory = true
            label.numberOfLines = 0
        }
        tagLabel.setContentHuggingPriority(.required, for: .horizontal)
        tagLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    private func setUpImages() {
        let symbolConfiguration = UIImage.SymbolConfiguration(textStyle: .footnote, scale: .small)
        restrictionsIconView.preferredSymbolConfiguration = symbolConfiguration
        restrictionsIconView.tintColor = ColorToken.restriction
        chevronView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(
            textStyle: .footnote,
            scale: .medium
        )
        chevronView.tintColor = ColorToken.textTertiary
        [restrictionsIconView, chevronView].forEach { imageView in
            imageView.setContentHuggingPriority(.required, for: .horizontal)
            imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        }
    }

    private func setUpLayout() {
        let nameRow = UIStackView(arrangedSubviews: [avatarView, nameLabel, tagLabel, chevronView])
        nameRow.spacing = SpacingToken.small
        nameRow.alignment = .center
        nameRow.setCustomSpacing(SpacingToken.xSmall, after: tagLabel)

        let titleRow = UIStackView(arrangedSubviews: [restrictionsIconView, restrictionsTitleLabel])
        titleRow.spacing = SpacingToken.xxSmall
        titleRow.alignment = .center

        pillsStack.axis = .vertical
        pillsStack.alignment = .leading
        pillsStack.spacing = SpacingToken.xSmall - 2

        restrictionsStack.addArrangedSubview(titleRow)
        restrictionsStack.addArrangedSubview(pillsStack)
        restrictionsStack.axis = .vertical
        restrictionsStack.alignment = .leading
        restrictionsStack.spacing = SpacingToken.xSmall
        restrictionsStack.isHidden = true

        // Error and restrictions line up with the name, after the avatar.
        let detailsStack = UIStackView(arrangedSubviews: [errorLabel, restrictionsStack])
        detailsStack.axis = .vertical
        detailsStack.spacing = SpacingToken.xSmall
        let detailsInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: SizeToken.avatarSmall + SpacingToken.small,
            bottom: 0,
            trailing: 0
        )
        detailsWrapper.isHidden = true
        detailsWrapper.addSubviewsForAutoLayout(detailsStack)
        NSLayoutConstraint.activate(detailsStack.constraintsPinningEdges(to: detailsWrapper, insets: detailsInsets))

        let contentStack = UIStackView(arrangedSubviews: [nameRow, detailsWrapper])
        contentStack.axis = .vertical
        contentStack.spacing = SpacingToken.xSmall
        contentView.addSubviewsForAutoLayout(contentStack)

        let insets = NSDirectionalEdgeInsets(
            top: SpacingToken.small,
            leading: SpacingToken.medium,
            bottom: SpacingToken.small,
            trailing: SpacingToken.medium
        )
        NSLayoutConstraint.activate(contentStack.constraintsPinningEdges(to: contentView, insets: insets) + [
            nameRow.heightAnchor.constraint(greaterThanOrEqualToConstant: SizeToken.minimumTouchTarget - 8)
        ])
    }

    // MARK: - Background

    override func updateConfiguration(using state: UICellConfigurationState) {
        super.updateConfiguration(using: state)
        var background = UIBackgroundConfiguration.listGroupedCell().updated(for: state)
        background.cornerRadius = RadiusToken.card
        backgroundConfiguration = background
    }
}
