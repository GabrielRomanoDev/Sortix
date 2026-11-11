import UIKit

/// A list cell holding an editable text field, for lists built with `UICollectionView`.
///
/// Used to add participants (screen 3) and to edit a participant's name (screen 3b). Closures are
/// cleared on reuse, so the cell registration must assign them again with `[weak self]`.
@MainActor
final class TextFieldListCell: UICollectionViewListCell {
    struct Model: Equatable {
        var text: String
        var placeholder: String?
        var accessibilityLabel: String
        var returnKeyType: UIReturnKeyType = .default
        var autocapitalizationType: UITextAutocapitalizationType = .words
    }

    let textField = UITextField()

    /// Called on every edit with the field's current text.
    var onTextChange: ((String) -> Void)?

    /// Called when the person taps the return key. Return `true` to keep the keyboard open,
    /// as when adding several participants in a row.
    var onReturn: (() -> Bool)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpTextField()
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

    func configure(with model: Model) {
        if textField.text != model.text {
            textField.text = model.text
        }
        textField.placeholder = model.placeholder
        textField.accessibilityLabel = model.accessibilityLabel
        textField.returnKeyType = model.returnKeyType
        textField.autocapitalizationType = model.autocapitalizationType
    }

    private func setUpTextField() {
        textField.font = TypographyToken.font(for: .body)
        textField.textColor = ColorToken.textPrimary
        textField.adjustsFontForContentSizeCategory = true
        textField.clearButtonMode = .whileEditing
        textField.delegate = self
        textField.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.onTextChange?(self.textField.text ?? "")
        }, for: .editingChanged)

        contentView.addSubviewsForAutoLayout(textField)
        NSLayoutConstraint.activate(
            textField.constraintsPinningEdges(to: contentView.layoutMarginsGuide) + [
                contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: SizeToken.rowMinHeight)
            ]
        )
    }
}

extension TextFieldListCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let keepsFocus = onReturn?() ?? false
        if !keepsFocus {
            textField.resignFirstResponder()
        }
        return false
    }
}
