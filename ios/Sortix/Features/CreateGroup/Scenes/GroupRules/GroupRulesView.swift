import UIKit

/// Step 1 of the creation flow: the header with the progress bar, the form ("Nome do grupo",
/// "Regras" and "Observações") and the "Próximo" button at the bottom.
final class GroupRulesView: UIView {
    let headerView = ScreenHeaderView(step: (current: 1, total: CreateGroupStep.total))
    let formView = FormScrollView()
    let nameRow: TextFieldRow
    let maxGiftValueRow: CurrencyFieldRow
    let eventDateToggleRow: ToggleRow
    let eventDatePickerRow: DatePickerRow
    let locationRow: TextFieldRow
    let notesRow: TextViewRow
    let nextButton: PrimaryButton

    private let groupSection = FormSectionView(header: String(localized: .groupRulesNameLabel))
    private let rulesSection = FormSectionView(header: String(localized: .groupRulesSectionRules))
    private let notesSection = FormSectionView(
        header: String(localized: .groupRulesNotesLabel),
        footer: String(localized: .groupRulesNotesFooter)
    )

    /// - Parameter onNext: Called by the "Próximo" button. Assign it with `[weak self]`.
    init(currencyCode: String, locale: Locale, onNext: @escaping @MainActor () -> Void) {
        nameRow = TextFieldRow(
            placeholder: String(localized: .groupRulesNamePlaceholder),
            accessibilityLabel: String(localized: .groupRulesNameAccessibilityLabel)
        )
        maxGiftValueRow = CurrencyFieldRow(
            title: String(localized: .groupRulesMaxValueLabel),
            placeholder: String(localized: .groupRulesMaxValuePlaceholder),
            currencyCode: currencyCode,
            locale: locale
        )
        eventDateToggleRow = ToggleRow(title: String(localized: .groupRulesEventDateToggle))
        eventDatePickerRow = DatePickerRow(
            title: String(localized: .groupRulesEventDateLabel),
            accessibilityLabel: String(localized: .groupRulesEventDateToggle)
        )
        locationRow = TextFieldRow(
            title: String(localized: .groupRulesLocationLabel),
            placeholder: String(localized: .groupRulesLocationPlaceholder)
        )
        notesRow = TextViewRow(
            placeholder: String(localized: .groupRulesNotesPlaceholder),
            accessibilityLabel: String(localized: .groupRulesNotesLabel)
        )
        nextButton = PrimaryButton(title: String(localized: .groupRulesNext), action: onNext)
        super.init(frame: .zero)
        setUpFields()
        setUpSections()
        setUpLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported; GroupRulesView is built in code.")
    }

    /// The picker shows only while the event date toggle is on.
    func setEventDatePickerHidden(_ isHidden: Bool) {
        rulesSection.setRow(eventDatePickerRow, hidden: isHidden)
    }

    // MARK: - Setup

    private func setUpFields() {
        nameRow.textField.returnKeyType = .next
        nameRow.textField.autocapitalizationType = .sentences
        locationRow.textField.autocapitalizationType = .sentences
    }

    private func setUpSections() {
        groupSection.addRow(nameRow)

        rulesSection.addRow(maxGiftValueRow)
        rulesSection.addRow(eventDateToggleRow)
        rulesSection.addRow(eventDatePickerRow)
        rulesSection.addRow(locationRow)
        setEventDatePickerHidden(true)

        notesSection.addRow(notesRow)

        formView.addArrangedSubview(groupSection)
        formView.addArrangedSubview(rulesSection)
        formView.addArrangedSubview(notesSection)
    }

    private func setUpLayout() {
        backgroundColor = ColorToken.background
        let stack = UIStackView(arrangedSubviews: [headerView, formView, FooterActionView(button: nextButton)])
        stack.axis = .vertical
        addSubviewsForAutoLayout(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor)
        ])
    }
}
