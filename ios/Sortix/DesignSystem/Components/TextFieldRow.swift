import UIKit

/// A text field row for `FormSectionView`, with a validation message below it.
///
/// With a title, the title sits on the leading side and the value is right-aligned, like a settings
/// row. Without a title, the field fills the row and relies on its placeholder.
@MainActor
final class TextFieldRow: UIView {
    let textField = UITextField()

    /// Called on every edit with the field's current text.
    var onTextChange: ((String) -> Void)?

    /// Called when the person taps the return key.
    var onReturn: (() -> Void)?

    private let titleLabel = UILabel()
    private let errorLabel = InlineErrorLabel()

    /// - Parameters:
    ///   - title: Visible label from the String Catalog. Also used as the accessibility label.
    ///   - placeholder: Placeholder from the String Catalog.
    ///   - accessibilityLabel: Overrides the accessibility label, e.g. to add "obrigatório".
    init(title: String? = nil, placeholder: String? = nil, accessibilityLabel: String? = nil) {
        super.init(frame: .zero)
        setUpTitle(title)
        setUpTextField(hasTitle: title != nil)
        setTexts(title: title, placeholder: placeholder, accessibilityLabel: accessibilityLabel)
        setUpLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported; TextFieldRow is built in code.")
    }

    /// Shows the given text and validation message. Does not call `onTextChange`.
    func configure(text: String, errorMessage: String?) {
        if textField.text != text {
            textField.text = text
        }
        errorLabel.message = errorMessage
    }

    // MARK: - Texts

    private func setTexts(title: String?, placeholder: String?, accessibilityLabel: String?) {
        titleLabel.text = title
        textField.placeholder = placeholder
        textField.accessibilityLabel = accessibilityLabel ?? title ?? placeholder
    }

    // MARK: - Setup

    private func setUpTitle(_ title: String?) {
        titleLabel.font = TypographyToken.body
        titleLabel.textColor = ColorToken.textPrimary
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.numberOfLines = 0
        titleLabel.isHidden = title == nil
        titleLabel.isAccessibilityElement = false
    }

    private func setUpTextField(hasTitle: Bool) {
        textField.font = TypographyToken.body
        textField.textColor = hasTitle ? ColorToken.textSecondary : ColorToken.textPrimary
        textField.textAlignment = hasTitle ? .right : .natural
        textField.adjustsFontForContentSizeCategory = true
        textField.clearButtonMode = .whileEditing
        textField.delegate = self
        textField.addAction(UIAction { [weak self] _ in
            self?.onTextChange?(self?.textField.text ?? "")
        }, for: .editingChanged)
    }

    private func setUpLayout() {
        let fieldStack = UIStackView(arrangedSubviews: [titleLabel, textField])
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
}

extension TextFieldRow: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onReturn?()
        return false
    }
}
