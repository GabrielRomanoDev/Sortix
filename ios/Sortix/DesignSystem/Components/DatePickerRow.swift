import UIKit

/// A row with a compact `UIDatePicker` that picks a day, for `FormSectionView`.
@MainActor
final class DatePickerRow: UIView {
    let datePicker = UIDatePicker()

    /// Called when the person picks a date.
    var onDateChange: ((Date) -> Void)?

    private let titleLabel = UILabel()
    private let errorLabel = InlineErrorLabel()

    /// - Parameters:
    ///   - title: Optional label on the leading side; the picker then sits on the trailing side.
    ///   - accessibilityLabel: What the picker is for, from the String Catalog.
    init(title: String? = nil, accessibilityLabel: String) {
        super.init(frame: .zero)
        setUpTitle()
        setUpDatePicker(hasTitle: title != nil)
        setTexts(title: title, accessibilityLabel: accessibilityLabel)
        setUpLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported; DatePickerRow is built in code.")
    }

    /// Shows the given date, the earliest date allowed and the validation message. Does not call
    /// `onDateChange`.
    func configure(date: Date, minimumDate: Date?, errorMessage: String?) {
        datePicker.minimumDate = minimumDate
        if datePicker.date != date {
            datePicker.setDate(date, animated: false)
        }
        errorLabel.message = errorMessage
    }

    // MARK: - Texts

    private func setTexts(title: String?, accessibilityLabel: String) {
        titleLabel.text = title
        titleLabel.isHidden = title == nil
        datePicker.accessibilityLabel = accessibilityLabel
    }

    // MARK: - Setup

    private func setUpTitle() {
        titleLabel.font = TypographyToken.body
        titleLabel.textColor = ColorToken.textPrimary
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.numberOfLines = 0
        titleLabel.isAccessibilityElement = false
    }

    private func setUpDatePicker(hasTitle: Bool) {
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.tintColor = ColorToken.accent
        datePicker.contentHorizontalAlignment = hasTitle ? .trailing : .leading
        datePicker.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            onDateChange?(datePicker.date)
        }, for: .valueChanged)
    }

    private func setUpLayout() {
        let fieldStack = UIStackView(arrangedSubviews: [titleLabel, datePicker])
        fieldStack.spacing = SpacingToken.small
        fieldStack.alignment = .center

        let stack = UIStackView(arrangedSubviews: [fieldStack, errorLabel])
        stack.axis = .vertical
        stack.spacing = SpacingToken.xxSmall
        addSubviewsForAutoLayout(stack)

        let insets = NSDirectionalEdgeInsets(
            top: SpacingToken.xSmall,
            leading: SpacingToken.medium,
            bottom: SpacingToken.xSmall,
            trailing: SpacingToken.medium
        )
        NSLayoutConstraint.activate(stack.constraintsPinningEdges(to: self, insets: insets) + [
            heightAnchor.constraint(greaterThanOrEqualToConstant: SizeToken.rowMinHeight)
        ])
    }
}
