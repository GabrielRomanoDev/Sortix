import UIKit

/// A small avatar and a name inside a gray capsule. Lists the people in a restriction.
@MainActor
final class PersonPillView: UIView {
    private let avatarView = AvatarView(diameter: SizeToken.avatarMini)
    private let nameLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpStyle()
        setUpLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported; PersonPillView is built in code.")
    }

    func configure(name: String, colors: ColorToken.AvatarColors) {
        avatarView.configure(name: name, colors: colors)
        nameLabel.text = name
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }

    private func setUpStyle() {
        backgroundColor = ColorToken.pill
        nameLabel.font = TypographyToken.subheadline
        nameLabel.textColor = ColorToken.textPrimary
        nameLabel.adjustsFontForContentSizeCategory = true
        nameLabel.numberOfLines = 0
    }

    private func setUpLayout() {
        let stack = UIStackView(arrangedSubviews: [avatarView, nameLabel])
        stack.spacing = SpacingToken.xSmall - 2
        stack.alignment = .center
        addSubviewsForAutoLayout(stack)
        let insets = NSDirectionalEdgeInsets(
            top: SpacingToken.xxSmall,
            leading: SpacingToken.xxSmall,
            bottom: SpacingToken.xxSmall,
            trailing: SpacingToken.small
        )
        NSLayoutConstraint.activate(stack.constraintsPinningEdges(to: self, insets: insets))
    }
}
