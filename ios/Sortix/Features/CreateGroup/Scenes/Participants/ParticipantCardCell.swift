import UIKit

/// One participant, shown as its own card: the name on the left with the pencil on the same line,
/// and below them, who this person cannot draw:
///
///     Gabriel (Você)              ✎
///     Não pode tirar
///     ↳ João
///     ↳ Karla
///
/// The padding is fixed on every side, so the card grows with the restrictions and the bottom
/// padding stays below the last name. Tapping anywhere on the card opens the edit screen.
final class ParticipantCardCell: UICollectionViewListCell {
    private let nameLabel = UILabel()
    private let errorLabel = InlineErrorLabel()
    private let restrictionsTitleLabel = UILabel()
    private let restrictionsStack = UIStackView()
    private let contentStack = UIStackView()
    private let pencilView = UIImageView(image: IconToken.edit.image)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpLabels()
        setUpPencil()
        setUpLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported; ParticipantCardCell is built in code.")
    }

    /// - Parameters:
    ///   - name: The name to show, or the hint when the organizer has no name yet.
    ///   - isPlaceholder: Shows `name` in the secondary color, as a hint.
    ///   - tag: "(Você)" after the organizer's name.
    ///   - forbiddenReceiverNames: Who this person cannot draw.
    ///   - errorMessage: A problem with the name, shown in red below it.
    func configure(
        name: String,
        isPlaceholder: Bool,
        tag: String?,
        forbiddenReceiverNames: [String],
        errorMessage: String?
    ) {
        setTexts(name: name, isPlaceholder: isPlaceholder, tag: tag, errorMessage: errorMessage)
        setRestrictions(forbiddenReceiverNames)
        accessibilityLabel = makeAccessibilityLabel(name: name, tag: tag, receivers: forbiddenReceiverNames)
        // The number of restrictions changes the card's height.
        invalidateIntrinsicContentSize()
    }

    // MARK: - Texts

    private func setTexts(name: String, isPlaceholder: Bool, tag: String?, errorMessage: String?) {
        nameLabel.attributedText = makeNameText(name: name, isPlaceholder: isPlaceholder, tag: tag)
        errorLabel.message = errorMessage
        restrictionsTitleLabel.text = String(localized: .participantsRestrictionsTitle)
    }

    private func makeNameText(name: String, isPlaceholder: Bool, tag: String?) -> NSAttributedString {
        let nameColor = isPlaceholder ? ColorToken.textSecondary : ColorToken.textPrimary
        let text = NSMutableAttributedString(string: name, attributes: [.foregroundColor: nameColor])
        if let tag {
            text.append(NSAttributedString(string: " \(tag)", attributes: [.foregroundColor: ColorToken.textSecondary]))
        }
        return text
    }

    private func setRestrictions(_ names: [String]) {
        restrictionsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        restrictionsStack.addArrangedSubview(restrictionsTitleLabel)
        names.forEach { restrictionsStack.addArrangedSubview(makeRestrictionRow(name: $0)) }
        restrictionsStack.isHidden = names.isEmpty
    }

    private func makeAccessibilityLabel(name: String, tag: String?, receivers: [String]) -> String {
        var parts = [name]
        if let tag {
            parts.append(tag)
        }
        if let error = errorLabel.message {
            parts.append(error)
        }
        if !receivers.isEmpty {
            parts.append(restrictionsTitleLabel.text ?? "")
            parts.append(receivers.formatted(.list(type: .and)))
        }
        return parts.joined(separator: ", ")
    }

    // MARK: - Setup

    private func setUpLabels() {
        nameLabel.font = TypographyToken.body
        restrictionsTitleLabel.font = TypographyToken.footnote
        restrictionsTitleLabel.textColor = ColorToken.textSecondary
        [nameLabel, restrictionsTitleLabel].forEach { label in
            label.adjustsFontForContentSizeCategory = true
            label.numberOfLines = 0
        }
    }

    private func setUpPencil() {
        pencilView.tintColor = ColorToken.accent
        pencilView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(font: TypographyToken.body)
        pencilView.setContentHuggingPriority(.required, for: .horizontal)
        pencilView.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    private func setUpLayout() {
        let nameRow = UIStackView(arrangedSubviews: [nameLabel, pencilView])
        nameRow.spacing = SpacingToken.small
        nameRow.alignment = .center

        restrictionsStack.axis = .vertical
        restrictionsStack.alignment = .leading
        restrictionsStack.spacing = SpacingToken.xxSmall

        contentStack.addArrangedSubview(nameRow)
        contentStack.addArrangedSubview(errorLabel)
        contentStack.addArrangedSubview(restrictionsStack)
        contentStack.axis = .vertical
        contentStack.spacing = SpacingToken.xSmall

        contentView.addSubviewsForAutoLayout(contentStack)
        let padding = NSDirectionalEdgeInsets(
            top: SpacingToken.medium,
            leading: SpacingToken.medium,
            bottom: SpacingToken.medium,
            trailing: SpacingToken.medium
        )
        NSLayoutConstraint.activate(contentStack.constraintsPinningEdges(to: contentView, insets: padding))
        isAccessibilityElement = true
        accessibilityTraits = .button
    }

    private func makeRestrictionRow(name: String) -> UIView {
        let branch = UIImageView(image: IconToken.restrictionBranch.image)
        branch.tintColor = ColorToken.textTertiary
        branch.preferredSymbolConfiguration = UIImage.SymbolConfiguration(font: TypographyToken.footnote)
        branch.setContentHuggingPriority(.required, for: .horizontal)

        let label = UILabel()
        label.text = name
        label.font = TypographyToken.subheadline
        label.textColor = ColorToken.textPrimary
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0

        let row = UIStackView(arrangedSubviews: [branch, label])
        row.spacing = SpacingToken.xSmall
        row.alignment = .center
        return row
    }
}
