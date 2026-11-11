import UIKit

/// A text field row for `FormSectionView`, with an inline validation message below it.
///
/// With a title, the title sits on the leading side and the value is right-aligned, like a settings
/// row; at accessibility text sizes the two stack vertically. Without a title, the field fills the
/// row and relies on its placeholder.
@MainActor
final class TextFieldRow: UIView {
    struct Model: Equatable {
        var text: String
        var errorMessage: String?
    }

    let textField = UITextField()

    /// Called on every edit with the field's current text.
    var onTextChange: ((String) -> Void)?

    /// Called when the person taps the return key.
    var onReturn: (() -> Void)?

    private let titleLabel = UILabel()
    private let errorLabel = InlineErrorLabel()
    private let fieldStack = UIStackView()
    private let hasTitle: Bool

    /// - Parameters:
    ///   - title: Visible label from the String Catalog. Also used as the accessibility label.
    ///   - placeholder: Placeholder from the String Catalog.
    ///   - accessibilityLabel: Overrides the accessibility label, e.g. to add "obrigatório".
    init(title: String? = nil, placeholder: String? = nil, accessibilityLabel: String? = nil) {
        hasTitle = title != nil
        super.init(frame: .zero)
        setUpTitle(title)
        setUpTextField(placeholder: placeholder, accessibilityLabel: accessibilityLabel ?? title ?? placeholder)
        setUpLayout()
        updateAxis()
        registerForTraitChanges([UITraitPreferredContentSizeCategory.self]) { (row: TextFieldRow, _) in
            row.updateAxis()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported; TextFieldRow is built in code.")
    }

    /// Applies ready-to-display data. Does not trigger `onTextChange`.
    func configure(with model: Model) {
        if textField.text != model.text {
            textField.text = model.text
        }
        errorLabel.message = model.errorMessage
    }

    // MARK: - Setup

    private func setUpTitle(_ title: String?) {
        titleLabel.text = title
        titleLabel.font = TypographyToken.font(for: .body)
        titleLabel.textColor = ColorToken.textPrimary
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.numberOfLines = 0
        titleLabel.isHidden = !hasTitle
        titleLabel.isAccessibilityElement = false
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }

    private func setUpTextField(placeholder: String?, accessibilityLabel: String?) {
        textField.placeholder = placeholder
        textField.font = TypographyToken.font(for: .body)
        textField.textColor = hasTitle ? ColorToken.textSecondary : ColorToken.textPrimary
        textField.adjustsFontForContentSizeCategory = true
        textField.clearButtonMode = .whileEditing
        textField.accessibilityLabel = accessibilityLabel
        textField.delegate = self
        textField.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        textField.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.onTextChange?(self.textField.text ?? "")
        }, for: .editingChanged)
    }

    private func setUpLayout() {
        fieldStack.addArrangedSubview(titleLabel)
        fieldStack.addArrangedSubview(textField)
        fieldStack.spacing = SpacingToken.small
        fieldStack.alignment = .center

        let stack = UIStackView(arrangedSubviews: [fieldStack, errorLabel])
        stack.axis = .vertical
        stack.spacing = SpacingToken.xxSmall
        addSubviewsForAutoLayout(stack)

        let insets = NSDirectionalEdgeInsets(
            top: SpacingToken.small,
            leading: SpacingToken.medium,
            bottom: SpacingToken.small,
            trailing: SpacingToken.medium
        )
        NSLayoutConstraint.activate(stack.constraintsPinningEdges(to: self, insets: insets) + [
            heightAnchor.constraint(greaterThanOrEqualToConstant: SizeToken.rowMinHeight),
            textField.heightAnchor.constraint(greaterThanOrEqualToConstant: SizeToken.minimumTouchTarget)
        ])
    }

    private func updateAxis() {
        let isAccessibilitySize = traitCollection.preferredContentSizeCategory.isAccessibilityCategory
        let stacksVertically = hasTitle && isAccessibilitySize
        fieldStack.axis = stacksVertically ? .vertical : .horizontal
        fieldStack.alignment = stacksVertically ? .fill : .center
        textField.textAlignment = hasTitle && !stacksVertically ? .right : .natural
    }
}

extension TextFieldRow: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onReturn?()
        return false
    }
}
