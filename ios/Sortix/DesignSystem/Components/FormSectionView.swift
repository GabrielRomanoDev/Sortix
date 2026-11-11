import UIKit

/// A grouped section of a form: optional uppercase header, rounded container with rows separated by
/// hairlines, and optional footer. Reproduces the `insetGrouped` list look outside a list.
@MainActor
final class FormSectionView: UIView {
    private let headerLabel = UILabel()
    private let footerLabel = UILabel()
    private let container = UIView()
    private let rowsStack = UIStackView()

    /// - Parameters:
    ///   - header: Section title from the String Catalog, displayed in uppercase.
    ///   - footer: Supporting text below the container, from the String Catalog.
    init(header: String? = nil, footer: String? = nil) {
        super.init(frame: .zero)
        setUpLabels(header: header, footer: footer)
        setUpContainer()
        setUpLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported; FormSectionView is built in code.")
    }

    /// Number of rows added with `addRow(_:)`.
    private(set) var rowCount = 0

    /// Appends a row. A hairline separator is inserted between consecutive rows.
    func addRow(_ row: UIView) {
        if rowCount > 0 {
            rowsStack.addArrangedSubview(makeSeparator())
        }
        rowsStack.addArrangedSubview(row)
        rowCount += 1
    }

    // MARK: - Setup

    private func setUpLabels(header: String?, footer: String?) {
        headerLabel.text = header?.uppercased()
        headerLabel.font = TypographyToken.font(for: .sectionHeader)
        headerLabel.textColor = ColorToken.textSecondary
        headerLabel.accessibilityTraits = .header
        headerLabel.isHidden = header == nil

        footerLabel.text = footer
        footerLabel.font = TypographyToken.font(for: .footnote)
        footerLabel.textColor = ColorToken.textSecondary
        footerLabel.isHidden = footer == nil

        [headerLabel, footerLabel].forEach { label in
            label.adjustsFontForContentSizeCategory = true
            label.numberOfLines = 0
        }
    }

    private func setUpContainer() {
        container.backgroundColor = ColorToken.surface
        container.layer.cornerRadius = RadiusToken.field
        container.layer.cornerCurve = .continuous
        container.clipsToBounds = true

        rowsStack.axis = .vertical
        container.addSubviewsForAutoLayout(rowsStack)
        NSLayoutConstraint.activate(rowsStack.constraintsPinningEdges(to: container))
    }

    private func setUpLayout() {
        let labelInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: SpacingToken.xxSmall,
            bottom: 0,
            trailing: SpacingToken.xxSmall
        )
        let headerWrapper = wrap(headerLabel, insets: labelInsets)
        let footerWrapper = wrap(footerLabel, insets: labelInsets)
        headerWrapper.isHidden = headerLabel.isHidden
        footerWrapper.isHidden = footerLabel.isHidden

        let stack = UIStackView(arrangedSubviews: [headerWrapper, container, footerWrapper])
        stack.axis = .vertical
        stack.spacing = SpacingToken.xSmall
        addSubviewsForAutoLayout(stack)
        NSLayoutConstraint.activate(stack.constraintsPinningEdges(to: self))
    }

    private func wrap(_ label: UILabel, insets: NSDirectionalEdgeInsets) -> UIView {
        let wrapper = UIView()
        wrapper.addSubviewsForAutoLayout(label)
        NSLayoutConstraint.activate(label.constraintsPinningEdges(to: wrapper, insets: insets))
        return wrapper
    }

    private func makeSeparator() -> UIView {
        let wrapper = UIView()
        let hairline = HairlineView()
        wrapper.addSubviewsForAutoLayout(hairline)
        let insets = NSDirectionalEdgeInsets(top: 0, leading: SpacingToken.medium, bottom: 0, trailing: 0)
        NSLayoutConstraint.activate(hairline.constraintsPinningEdges(to: wrapper, insets: insets))
        return wrapper
    }
}
