import UIKit

final class GroupRulesViewController: UIViewController {
    private let viewModel: GroupRulesViewModel
    private lazy var rulesView = GroupRulesView(currencyCode: viewModel.currencyCode, locale: viewModel.locale)
    /// The last state shown, used to announce only errors that just appeared.
    private var renderedState: GroupRulesState?

    init(viewModel: GroupRulesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported; GroupRulesViewController is built in code.")
    }

    override func loadView() {
        view = rulesView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationItem()
        setUpFieldActions()
        viewModel.onStateChange = { [weak self] state in
            self?.render(state)
        }
        render(viewModel.state)
        viewModel.viewDidLoad()
    }

    // MARK: - Setup

    private func setUpNavigationItem() {
        title = String(localized: .groupRulesTitle)
        navigationItem.largeTitleDisplayMode = .never

        let cancelAction = UIAction { [weak self] _ in
            self?.viewModel.didTapCancel()
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(systemItem: .cancel, primaryAction: cancelAction)

        let nextAction = UIAction(title: String(localized: .commonActionNext)) { [weak self] _ in
            self?.viewModel.didTapNext()
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(primaryAction: nextAction)
    }

    private func setUpFieldActions() {
        rulesView.nameRow.onTextChange = { [weak self] text in
            self?.viewModel.didChangeName(text)
        }
        rulesView.nameRow.onReturn = { [weak self] in
            self?.rulesView.maxGiftValueRow.textField.becomeFirstResponder()
        }
        rulesView.maxGiftValueRow.onAmountChange = { [weak self] amountMinor in
            self?.viewModel.didChangeMaxGiftValue(amountMinor)
        }
        rulesView.eventDateToggleRow.onToggle = { [weak self] isOn in
            self?.viewModel.didToggleEventDate(isOn)
        }
        rulesView.eventDatePickerRow.onDateChange = { [weak self] date in
            self?.viewModel.didChangeEventDate(date)
        }
        rulesView.locationRow.onTextChange = { [weak self] text in
            self?.viewModel.didChangeLocation(text)
        }
        rulesView.notesRow.onTextChange = { [weak self] text in
            self?.viewModel.didChangeNotes(text)
        }
    }

    // MARK: - Rendering

    private func render(_ state: GroupRulesState) {
        rulesView.nameRow.configure(text: state.name, errorMessage: nameMessage(for: state.nameError))
        rulesView.maxGiftValueRow.configure(
            amountMinor: state.maxGiftValue?.amountMinor,
            errorMessage: maxGiftValueMessage(for: state)
        )
        renderEventDate(state)
        rulesView.locationRow.configure(text: state.location, errorMessage: tooLongMessage(for: state.locationError))
        rulesView.notesRow.configure(text: state.notes, errorMessage: tooLongMessage(for: state.notesError))
        navigationItem.rightBarButtonItem?.isEnabled = state.isNextEnabled
        announceNewError(in: state)
        renderedState = state
    }

    private func renderEventDate(_ state: GroupRulesState) {
        rulesView.eventDateToggleRow.configure(isOn: state.eventDate != nil)
        rulesView.setEventDatePickerHidden(state.eventDate == nil)
        guard let eventDate = state.eventDate else { return }
        rulesView.eventDatePickerRow.configure(
            date: eventDate,
            minimumDate: viewModel.minimumEventDate,
            errorMessage: state.eventDateError == nil ? nil : String(localized: .groupRulesEventDateErrorPast)
        )
    }

    // MARK: - Error messages

    private func nameMessage(for error: ValidationError?) -> String? {
        if error == .empty {
            return String(localized: .groupRulesNameErrorEmpty)
        }
        return tooLongMessage(for: error)
    }

    private func maxGiftValueMessage(for state: GroupRulesState) -> String? {
        guard state.maxGiftValueError != nil, let value = state.maxGiftValue else { return nil }
        if value.amountMinor <= 0 {
            return String(localized: .groupRulesMaxValueErrorZero)
        }
        let limit = Money(amountMinor: FieldLimits.maxGiftValueMinor, currencyCode: value.currencyCode)
        let formattedLimit = limit.amount.formatted(.currency(code: limit.currencyCode).locale(viewModel.locale))
        return String(localized: .groupRulesMaxValueErrorTooHigh(formattedLimit))
    }

    private func tooLongMessage(for error: ValidationError?) -> String? {
        guard case .tooLong(let limit) = error else { return nil }
        return String(localized: .validationTooLong(limit))
    }

    // MARK: - Accessibility

    /// VoiceOver reads an error as soon as it appears (section 5.2).
    private func announceNewError(in state: GroupRulesState) {
        let rows: [(error: ValidationError?, previous: ValidationError?, view: UIView)] = [
            (state.nameError, renderedState?.nameError, rulesView.nameRow),
            (state.maxGiftValueError, renderedState?.maxGiftValueError, rulesView.maxGiftValueRow),
            (state.locationError, renderedState?.locationError, rulesView.locationRow),
            (state.notesError, renderedState?.notesError, rulesView.notesRow)
        ]
        guard let row = rows.first(where: { $0.error != nil && $0.previous == nil }) else { return }
        UIAccessibility.post(notification: .layoutChanged, argument: row.view)
    }
}
