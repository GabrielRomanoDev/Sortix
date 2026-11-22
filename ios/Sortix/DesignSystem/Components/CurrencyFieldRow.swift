import UIKit

/// A money field row for `FormSectionView`. Digits fill the cents from right to left and the value
/// is shown formatted, such as "R$ 50,00".
///
/// Typing only zeros, or deleting every digit, clears the field, which means "no value".
@MainActor
final class CurrencyFieldRow: UIView {
    let textField = UITextField()

    /// Called on every edit with the amount in cents, or `nil` when the field is empty.
    var onAmountChange: ((Int?) -> Void)?

    private let titleLabel = UILabel()
    private let errorLabel = InlineErrorLabel()
    private let currencyCode: String
    private let locale: Locale

    /// - Parameters:
    ///   - title: Visible label from the String Catalog. Also used as the accessibility label.
    ///   - placeholder: Placeholder from the String Catalog, shown while there is no value.
    ///   - currencyCode: ISO 4217 code used to format the value, such as `BRL`.
    ///   - locale: Locale used to format the value.
    init(title: String, placeholder: String?, currencyCode: String, locale: Locale) {
        self.currencyCode = currencyCode
        self.locale = locale
        super.init(frame: .zero)
        setUpTitle()
        setUpTextField()
        setTexts(title: title, placeholder: placeholder)
        setUpLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported; CurrencyFieldRow is built in code.")
    }

    /// Shows the given amount and validation message. Does not call `onAmountChange`.
    func configure(amountMinor: Int?, errorMessage: String?) {
        let text = formattedText(for: amountMinor)
        if textField.text != text {
            textField.text = text
        }
        errorLabel.message = errorMessage
    }

    // MARK: - Texts

    private func setTexts(title: String, placeholder: String?) {
        titleLabel.text = title
        textField.placeholder = placeholder
        textField.accessibilityLabel = title
    }

    // MARK: - Setup

    private func setUpTitle() {
        titleLabel.font = TypographyToken.body
        titleLabel.textColor = ColorToken.textPrimary
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.numberOfLines = 0
        titleLabel.isAccessibilityElement = false
    }

    private func setUpTextField() {
        textField.font = TypographyToken.body
        textField.textColor = ColorToken.textSecondary
        textField.textAlignment = .right
        textField.adjustsFontForContentSizeCategory = true
        textField.keyboardType = .numberPad
        textField.addAction(UIAction { [weak self] _ in
            self?.handleEditing()
        }, for: .editingChanged)
    }

    private func setUpLayout() {
        let stack = UIStackView(arrangedSubviews: [titleLabel, textField])
        stack.spacing = SpacingToken.small
        stack.alignment = .center

        let verticalStack = UIStackView(arrangedSubviews: [stack, errorLabel])
        verticalStack.axis = .vertical
        verticalStack.spacing = SpacingToken.xxSmall
        addSubviewsForAutoLayout(verticalStack)

        let insets = NSDirectionalEdgeInsets(
            top: SpacingToken.small,
            leading: SpacingToken.medium,
            bottom: SpacingToken.small,
            trailing: SpacingToken.medium
        )
        NSLayoutConstraint.activate(verticalStack.constraintsPinningEdges(to: self, insets: insets) + [
            heightAnchor.constraint(greaterThanOrEqualToConstant: SizeToken.rowMinHeight),
            textField.heightAnchor.constraint(greaterThanOrEqualToConstant: SizeToken.minimumTouchTarget)
        ])
    }

    // MARK: - Editing

    private func handleEditing() {
        let amountMinor = amount(from: textField.text ?? "")
        textField.text = formattedText(for: amountMinor)
        onAmountChange?(amountMinor)
    }

    /// Without this, deleting from "R$ 0,05" would leave "R$ 0,00" forever.
    private func amount(from text: String) -> Int? {
        guard let amountMinor = CurrencyInputParser.amountMinor(from: text), amountMinor > 0 else {
            return nil
        }
        return amountMinor
    }

    private func formattedText(for amountMinor: Int?) -> String {
        guard let amountMinor else { return "" }
        let money = Money(amountMinor: amountMinor, currencyCode: currencyCode)
        return money.amount.formatted(.currency(code: currencyCode).locale(locale))
    }
}
