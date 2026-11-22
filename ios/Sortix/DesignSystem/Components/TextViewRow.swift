import UIKit

/// A multi-line text row for `FormSectionView`, with the title above the text, a placeholder and a
/// validation message below it. Used for notes.
@MainActor
final class TextViewRow: UIView {
    let textView = UITextView()

    /// Called on every edit with the current text.
    var onTextChange: ((String) -> Void)?

    private let titleLabel = UILabel()
    private let placeholderLabel = UILabel()
    private let errorLabel = InlineErrorLabel()

    /// - Parameters:
    ///   - title: Visible label from the String Catalog. Also used as the accessibility label.
    ///   - placeholder: Placeholder from the String Catalog, shown while the text is empty.
    init(title: String, placeholder: String? = nil) {
        super.init(frame: .zero)
        setUpTitle()
        setUpTextView()
        setUpPlaceholder()
        setTexts(title: title, placeholder: placeholder)
        setUpLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported; TextViewRow is built in code.")
    }

    /// Shows the given text and validation message. Does not call `onTextChange`.
    func configure(text: String, errorMessage: String?) {
        if textView.text != text {
            textView.text = text
        }
        updatePlaceholderVisibility()
        errorLabel.message = errorMessage
    }

    // MARK: - Texts

    private func setTexts(title: String, placeholder: String?) {
        titleLabel.text = title
        placeholderLabel.text = placeholder
        textView.accessibilityLabel = title
    }

    // MARK: - Setup

    private func setUpTitle() {
        titleLabel.font = TypographyToken.body
        titleLabel.textColor = ColorToken.textPrimary
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.numberOfLines = 0
        titleLabel.isAccessibilityElement = false
    }

    private func setUpTextView() {
        textView.font = TypographyToken.body
        textView.textColor = ColorToken.textPrimary
        textView.backgroundColor = .clear
        textView.adjustsFontForContentSizeCategory = true
        textView.isScrollEnabled = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.delegate = self
    }

    private func setUpPlaceholder() {
        placeholderLabel.font = TypographyToken.body
        placeholderLabel.textColor = ColorToken.textTertiary
        placeholderLabel.adjustsFontForContentSizeCategory = true
        placeholderLabel.numberOfLines = 0
        placeholderLabel.isAccessibilityElement = false
    }

    private func setUpLayout() {
        textView.addSubviewsForAutoLayout(placeholderLabel)
        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor),
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor),
            placeholderLabel.widthAnchor.constraint(equalTo: textView.widthAnchor)
        ])

        let stack = UIStackView(arrangedSubviews: [titleLabel, textView, errorLabel])
        stack.axis = .vertical
        stack.spacing = SpacingToken.xSmall
        addSubviewsForAutoLayout(stack)

        let insets = NSDirectionalEdgeInsets(
            top: SpacingToken.small,
            leading: SpacingToken.medium,
            bottom: SpacingToken.small,
            trailing: SpacingToken.medium
        )
        NSLayoutConstraint.activate(stack.constraintsPinningEdges(to: self, insets: insets) + [
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: SizeToken.textViewMinHeight)
        ])
    }

    private func updatePlaceholderVisibility() {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}

extension TextViewRow: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updatePlaceholderVisibility()
        onTextChange?(textView.text)
    }
}
