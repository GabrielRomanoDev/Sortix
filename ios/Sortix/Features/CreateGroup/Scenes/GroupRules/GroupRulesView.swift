import UIKit

/// The rules form: a "Grupo" section with the name and an optional "Regras" section.
final class GroupRulesView: UIView {
    let formView = FormScrollView()
    let nameRow: TextFieldRow
    let maxGiftValueRow: CurrencyFieldRow
    let eventDateToggleRow: ToggleRow
    let eventDatePickerRow: DatePickerRow
    let locationRow: TextFieldRow
    let notesRow: TextViewRow

    private let groupSection = FormSectionView(header: String(localized: .groupRulesSectionGroup))
    private let rulesSection = FormSectionView(header: String(localized: .groupRulesSectionRules))

    init(currencyCode: String, locale: Locale) {
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
        eventDatePickerRow = DatePickerRow(accessibilityLabel: String(localized: .groupRulesEventDateToggle))
        locationRow = TextFieldRow(
            title: String(localized: .groupRulesLocationLabel),
            placeholder: String(localized: .groupRulesLocationPlaceholder)
        )
        notesRow = TextViewRow(
            title: String(localized: .groupRulesNotesLabel),
            placeholder: String(localized: .groupRulesNotesPlaceholder)
        )
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
        rulesSection.addRow(notesRow)
        setEventDatePickerHidden(true)

        formView.addArrangedSubview(groupSection)
        formView.addArrangedSubview(rulesSection)
    }

    private func setUpLayout() {
        backgroundColor = ColorToken.background
        addSubviewsForAutoLayout(formView)
        NSLayoutConstraint.activate([
            formView.topAnchor.constraint(equalTo: topAnchor),
            formView.leadingAnchor.constraint(equalTo: leadingAnchor),
            formView.trailingAnchor.constraint(equalTo: trailingAnchor),
            formView.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor)
        ])
    }
}
