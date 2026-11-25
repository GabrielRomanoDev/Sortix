import UIKit

/// A list section header with the uppercase title on the leading side and a short hint on the
/// trailing side, such as "5 PARTICIPANTES" and "Toque para editar".
@MainActor
final class ListSectionHeaderView: UICollectionReusableView {
    private let titleLabel = UILabel()
    private let detailLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpLabels()
        setUpLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported; ListSectionHeaderView is built in code.")
    }

    func configure(title: String, detail: String?) {
        titleLabel.text = title.uppercased()
        detailLabel.text = detail
        detailLabel.isHidden = detail == nil
    }

    private func setUpLabels() {
        titleLabel.font = TypographyToken.sectionHeader
        titleLabel.textColor = ColorToken.textSecondary
        titleLabel.accessibilityTraits = .header
        detailLabel.font = TypographyToken.footnote
        detailLabel.textColor = ColorToken.textSecondary
        detailLabel.textAlignment = .right
        [titleLabel, detailLabel].forEach { label in
            label.adjustsFontForContentSizeCategory = true
            label.numberOfLines = 0
        }
    }

    private func setUpLayout() {
        let stack = UIStackView(arrangedSubviews: [titleLabel, detailLabel])
        stack.spacing = SpacingToken.small
        stack.alignment = .firstBaseline
        addSubviewsForAutoLayout(stack)
        let insets = NSDirectionalEdgeInsets(
            top: SpacingToken.small,
            leading: SpacingToken.xxSmall,
            bottom: SpacingToken.xSmall,
            trailing: SpacingToken.xxSmall
        )
        NSLayoutConstraint.activate(stack.constraintsPinningEdges(to: self, insets: insets))
    }
}
