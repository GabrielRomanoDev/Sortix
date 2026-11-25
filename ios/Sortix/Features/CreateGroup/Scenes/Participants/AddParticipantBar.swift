import UIKit

/// The row that adds people, above the list: the name field, a button that opens the contacts and
/// "Adicionar". Errors show right below the field.
///
/// The keyboard stays open after a name is added, so several names can be typed in a row.
final class AddParticipantBar: UIView {
    let textField = UITextField()
    let contactsButton = UIButton(configuration: .filled())
    let addButton = UIButton(configuration: .filled())
    let errorLabel = InlineErrorLabel()

    /// Called on every edit with the field's current text.
    var onTextChange: ((String) -> Void)?
    /// Called by "Adicionar" and by the return key.
    var onAdd: (() -> Void)?
    var onPickContact: (() -> Void)?

    private let fieldContainer = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpTextField()
        setUpButtons()
        setUpLayout()
        // Keeps its own height in a vertical stack; the list or scroll view takes the rest.
        setContentHuggingPriority(.required, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .vertical)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported; AddParticipantBar is built in code.")
    }

    func setTexts(placeholder: String, accessibilityLabel: String, addTitle: String, contactsLabel: String) {
        textField.placeholder = placeholder
        textField.accessibilityLabel = accessibilityLabel
        addButton.configuration?.title = addTitle
        contactsButton.accessibilityLabel = contactsLabel
    }

    func configure(text: String, errorMessage: String?, isEnabled: Bool) {
        if textField.text != text {
            textField.text = text
        }
        errorLabel.message = errorMessage
        textField.isEnabled = isEnabled
        contactsButton.isEnabled = isEnabled
        addButton.isEnabled = isEnabled
    }

    // MARK: - Setup

    private func setUpTextField() {
        textField.font = TypographyToken.body
        textField.textColor = ColorToken.textPrimary
        textField.adjustsFontForContentSizeCategory = true
        textField.autocapitalizationType = .words
        textField.returnKeyType = .done
        textField.clearButtonMode = .whileEditing
        textField.delegate = self
        textField.addAction(UIAction { [weak self] _ in
            self?.onTextChange?(self?.textField.text ?? "")
        }, for: .editingChanged)

        fieldContainer.backgroundColor = ColorToken.surface
        fieldContainer.layer.cornerRadius = RadiusToken.field
        fieldContainer.layer.cornerCurve = .continuous
    }

    private func setUpButtons() {
        var contacts = UIButton.Configuration.filled()
        contacts.image = IconToken.person.image
        contacts.baseBackgroundColor = ColorToken.surface
        contacts.baseForegroundColor = ColorToken.accent
        contacts.cornerStyle = .fixed
        contacts.background.cornerRadius = RadiusToken.field
        contactsButton.configuration = contacts
        contactsButton.addAction(UIAction { [weak self] _ in
            self?.onPickContact?()
        }, for: .primaryActionTriggered)

        var add = UIButton.Configuration.filled()
        add.baseBackgroundColor = ColorToken.accent
        add.baseForegroundColor = ColorToken.onAccent
        add.cornerStyle = .fixed
        add.background.cornerRadius = RadiusToken.field
        add.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: SpacingToken.medium,
            bottom: 0,
            trailing: SpacingToken.medium
        )
        let font = TypographyToken.headline
        add.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
            var attributes = attributes
            attributes.font = font
            return attributes
        }
        addButton.configuration = add
        addButton.addAction(UIAction { [weak self] _ in
            self?.onAdd?()
        }, for: .primaryActionTriggered)
        addButton.setContentHuggingPriority(.required, for: .horizontal)
        addButton.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    private func setUpLayout() {
        fieldContainer.addSubviewsForAutoLayout(textField)
        let fieldInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: SpacingToken.medium,
            bottom: 0,
            trailing: SpacingToken.xSmall
        )
        NSLayoutConstraint.activate(textField.constraintsPinningEdges(to: fieldContainer, insets: fieldInsets))

        let row = UIStackView(arrangedSubviews: [fieldContainer, contactsButton, addButton])
        row.spacing = SpacingToken.xSmall

        let errorWrapper = UIView()
        errorWrapper.addSubviewsForAutoLayout(errorLabel)
        let errorInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: SpacingToken.xxSmall,
            bottom: 0,
            trailing: SpacingToken.xxSmall
        )
        NSLayoutConstraint.activate(errorLabel.constraintsPinningEdges(to: errorWrapper, insets: errorInsets))

        let stack = UIStackView(arrangedSubviews: [row, errorWrapper])
        stack.axis = .vertical
        stack.spacing = SpacingToken.xSmall
        addSubviewsForAutoLayout(stack)

        let insets = NSDirectionalEdgeInsets(
            top: 0,
            leading: SpacingToken.screenMargin,
            bottom: 0,
            trailing: SpacingToken.screenMargin
        )
        NSLayoutConstraint.activate(stack.constraintsPinningEdges(to: self, insets: insets) + [
            row.heightAnchor.constraint(greaterThanOrEqualToConstant: SizeToken.fieldButton),
            contactsButton.widthAnchor.constraint(equalToConstant: SizeToken.fieldButton)
        ])
    }
}

extension AddParticipantBar: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onAdd?()
        return false
    }
}
