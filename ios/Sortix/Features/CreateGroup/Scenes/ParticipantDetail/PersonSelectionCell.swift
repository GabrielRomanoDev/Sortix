import UIKit

/// A participant who can be marked: avatar, name and a selection circle, filled with a check when
/// marked. The mark comes from the state, not from the list's own selection.
final class PersonSelectionCell: UICollectionViewListCell {
    private let avatarView = AvatarView(diameter: SizeToken.avatarSmall)
    private let nameLabel = UILabel()
    private let indicatorView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
        setUpLayout()
        isAccessibilityElement = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported; PersonSelectionCell is built in code.")
    }

    func configure(name: String, colors: ColorToken.AvatarColors, isSelected: Bool) {
        avatarView.configure(name: name, colors: colors)
        nameLabel.text = name
        indicatorView.image = isSelected ? IconToken.selectionOn.image : IconToken.selectionOff.image
        indicatorView.tintColor = isSelected ? ColorToken.accent : ColorToken.textTertiary
        accessibilityLabel = name
        accessibilityTraits = isSelected ? [.button, .selected] : .button
    }

    private func setUpViews() {
        nameLabel.font = TypographyToken.body
        nameLabel.textColor = ColorToken.textPrimary
        nameLabel.adjustsFontForContentSizeCategory = true
        nameLabel.numberOfLines = 0
        indicatorView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(textStyle: .title3)
        indicatorView.setContentHuggingPriority(.required, for: .horizontal)
        indicatorView.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    private func setUpLayout() {
        let stack = UIStackView(arrangedSubviews: [avatarView, nameLabel, indicatorView])
        stack.spacing = SpacingToken.small
        stack.alignment = .center
        contentView.addSubviewsForAutoLayout(stack)
        let insets = NSDirectionalEdgeInsets(
            top: SpacingToken.small,
            leading: SpacingToken.medium,
            bottom: SpacingToken.small,
            trailing: SpacingToken.medium
        )
        NSLayoutConstraint.activate(stack.constraintsPinningEdges(to: contentView, insets: insets))
        separatorLayoutGuide.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor).isActive = true
    }
}
