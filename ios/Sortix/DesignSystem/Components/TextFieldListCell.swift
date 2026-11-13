import UIKit

/// A list cell holding an editable text field, for lists built with `UICollectionView`.
///
/// Used to add participants (screen 3) and to edit a participant's name (screen 3b). The keyboard
/// stays open on return, so several names can be typed in a row; call `resignFirstResponder()` on
/// `textField` to close it. Closures are cleared on reuse, so assign them again in the registration.
@MainActor
final class TextFieldListCell: UICollectionViewListCell {
    let textField = UITextField()

    /// Called on every edit with the field's current text.
    var onTextChange: ((String) -> Void)?

    /// Called when the person taps the return key.
    var onReturn: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpTextField()
        setUpLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported; TextFieldListCell is built in code.")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onTextChange = nil
        onReturn = nil
    }

    func configure(text: String, placeholder: String?, accessibilityLabel: String, returnKeyType: UIReturnKeyType) {
        if textField.text != text {
            textField.text = text
        }
        textField.placeholder = placeholder
        textField.accessibilityLabel = accessibilityLabel
        textField.returnKeyType = returnKeyType
    }

    // MARK: - Setup

    private func setUpTextField() {
        textField.font = TypographyToken.body
        textField.textColor = ColorToken.textPrimary
        textField.adjustsFontForContentSizeCategory = true
        textField.clearButtonMode = .whileEditing
        textField.delegate = self
        textField.addAction(UIAction { [weak self] _ in
            self?.onTextChange?(self?.textField.text ?? "")
        }, for: .editingChanged)
    }

    private func setUpLayout() {
        contentView.addSubviewsForAutoLayout(textField)
        NSLayoutConstraint.activate(textField.constraintsPinningEdges(to: contentView.layoutMarginsGuide) + [
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: SizeToken.rowMinHeight)
        ])
    }
}

extension TextFieldListCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onReturn?()
        return false
    }
}
