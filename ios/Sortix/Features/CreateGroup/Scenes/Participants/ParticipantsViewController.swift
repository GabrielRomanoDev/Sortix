import UIKit

final class ParticipantsViewController: UIViewController {
    /// Each person gets a section of their own, so every card has its own background and space
    /// around it.
    private enum Section: Hashable {
        case add
        case participant(ParticipantID)
    }

    private enum Item: Hashable {
        case addField
        case addError
        case addFromContacts
        case participant(ParticipantID)
    }

    private typealias CardCellRegistration = UICollectionView.CellRegistration<ParticipantCardCell, ParticipantID>
    private typealias AddFieldCellRegistration = UICollectionView.CellRegistration<TextFieldListCell, Item>
    private typealias ListCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item>

    private let viewModel: ParticipantsViewModel
    private lazy var participantsView = ParticipantsView(layout: makeLayout())
    private lazy var dataSource = makeDataSource()
    /// The last state shown. Cells read their content from it.
    private var renderedState = ParticipantsState()

    init(viewModel: ParticipantsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported; ParticipantsViewController is built in code.")
    }

    override func loadView() {
        view = participantsView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationItem()
        participantsView.collectionView.delegate = self
        viewModel.onStateChange = { [weak self] state in
            self?.render(state)
        }
        render(viewModel.state)
        viewModel.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewWillAppear()
    }

    // MARK: - Setup

    private func setUpNavigationItem() {
        title = String(localized: .participantsTitle)
        navigationItem.largeTitleDisplayMode = .never
        let reviewAction = UIAction(title: String(localized: .participantsNext)) { [weak self] _ in
            self?.viewModel.didTapReview()
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(primaryAction: reviewAction)
    }

    private func makeLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            configuration.headerMode = self?.hasHeader(sectionIndex) == true ? .supplementary : .none
            configuration.footerMode = self?.hasFooter(sectionIndex) == true ? .supplementary : .none
            configuration.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
                self?.swipeActions(at: indexPath)
            }
            let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: environment)
            if self?.hasHeader(sectionIndex) == false {
                section.contentInsets.top = 0
                section.contentInsets.bottom = SpacingToken.small
            }
            return section
        }
    }

    /// "Adicionar participantes" and the first card carry a header.
    private func hasHeader(_ sectionIndex: Int) -> Bool {
        sectionIndex <= 1
    }

    /// The last card carries the count.
    private func hasFooter(_ sectionIndex: Int) -> Bool {
        sectionIndex > 0 && sectionIndex == dataSource.snapshot().numberOfSections - 1
    }

    // MARK: - Rendering

    private func render(_ state: ParticipantsState) {
        let hadAddError = renderedState.addError != nil
        renderedState = state
        navigationItem.rightBarButtonItem?.isEnabled = state.isReviewEnabled
        applySnapshot(for: state)
        updateFooter()
        if !hadAddError && state.addError != nil {
            announceAddError()
        }
    }

    private func applySnapshot(for state: ParticipantsState) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.add])
        snapshot.appendItems([.addField], toSection: .add)
        if state.addError != nil {
            snapshot.appendItems([.addError], toSection: .add)
        }
        snapshot.appendItems([.addFromContacts], toSection: .add)

        let people = [state.organizer].compactMap { $0 } + state.participants
        for person in people {
            snapshot.appendSections([.participant(person.id)])
            snapshot.appendItems([.participant(person.id)], toSection: .participant(person.id))
        }
        // Rows keep their identity, so their content is refreshed explicitly.
        snapshot.reconfigureItems(snapshot.itemIdentifiers)
        dataSource.apply(snapshot, animatingDifferences: view.window != nil)
    }

    /// The count changes with every name, so the visible footer is refreshed by hand.
    private func updateFooter() {
        let lastSection = dataSource.snapshot().numberOfSections - 1
        guard hasFooter(lastSection) else { return }
        let footer = participantsView.collectionView.supplementaryView(
            forElementKind: UICollectionView.elementKindSectionFooter,
            at: IndexPath(item: 0, section: lastSection)
        ) as? UICollectionViewListCell
        footer?.contentConfiguration = makeFooterConfiguration()
    }

    /// VoiceOver reads the error as soon as it appears below the field.
    private func announceAddError() {
        guard
            let indexPath = dataSource.indexPath(for: .addError),
            let cell = participantsView.collectionView.cellForItem(at: indexPath)
        else { return }
        UIAccessibility.post(notification: .layoutChanged, argument: cell)
    }

    // MARK: - Data source

    private func makeDataSource() -> UICollectionViewDiffableDataSource<Section, Item> {
        let cardCell = makeCardCellRegistration()
        let addFieldCell = makeAddFieldCellRegistration()
        let listCell = makeListCellRegistration()
        let dataSource = UICollectionViewDiffableDataSource<Section, Item>(
            collectionView: participantsView.collectionView
        ) { collectionView, indexPath, item in
            switch item {
            case .participant(let id):
                collectionView.dequeueConfiguredReusableCell(using: cardCell, for: indexPath, item: id)
            case .addField:
                collectionView.dequeueConfiguredReusableCell(using: addFieldCell, for: indexPath, item: item)
            case .addError, .addFromContacts:
                collectionView.dequeueConfiguredReusableCell(using: listCell, for: indexPath, item: item)
            }
        }
        setUpSupplementaryViews(for: dataSource)
        return dataSource
    }

    private func setUpSupplementaryViews(for dataSource: UICollectionViewDiffableDataSource<Section, Item>) {
        let header = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { [weak self] view, _, indexPath in
            view.contentConfiguration = self?.makeHeaderConfiguration(forSectionAt: indexPath.section)
        }
        let footer = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(
            elementKind: UICollectionView.elementKindSectionFooter
        ) { [weak self] view, _, _ in
            view.contentConfiguration = self?.makeFooterConfiguration()
        }
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            let registration = kind == UICollectionView.elementKindSectionHeader ? header : footer
            return collectionView.dequeueConfiguredReusableSupplementary(using: registration, for: indexPath)
        }
    }

    // MARK: - Cells

    private func makeCardCellRegistration() -> CardCellRegistration {
        CardCellRegistration { [weak self] cell, _, id in
            self?.configure(cell, forParticipant: id)
        }
    }

    private func makeAddFieldCellRegistration() -> AddFieldCellRegistration {
        AddFieldCellRegistration { [weak self] cell, _, _ in
            guard let self else { return }
            cell.configure(
                text: renderedState.newName,
                placeholder: String(localized: .participantsAddPlaceholder),
                accessibilityLabel: String(localized: .participantsAddAccessibilityLabel),
                returnKeyType: .done
            )
            cell.textField.isEnabled = renderedState.isAddEnabled
            cell.textField.autocapitalizationType = .words
            cell.onTextChange = { [weak self] text in
                self?.viewModel.didChangeNewName(text)
            }
            cell.onReturn = { [weak self] in
                self?.viewModel.didTapAdd()
            }
        }
    }

    private func makeListCellRegistration() -> ListCellRegistration {
        ListCellRegistration { [weak self] cell, _, item in
            guard let self else { return }
            switch item {
            case .addError:
                configureAddError(cell)
            case .addFromContacts:
                configureContactsButton(cell)
            case .addField, .participant:
                break
            }
        }
    }

    private func configureAddError(_ cell: UICollectionViewListCell) {
        var content = cell.defaultContentConfiguration()
        content.text = renderedState.addError.map(addErrorText(for:))
        content.textProperties.font = TypographyToken.footnote
        content.textProperties.color = ColorToken.destructive
        content.image = IconToken.genericError.image
        content.imageProperties.tintColor = ColorToken.destructive
        cell.contentConfiguration = content
        cell.accessibilityTraits = .staticText
    }

    private func configureContactsButton(_ cell: UICollectionViewListCell) {
        let color = renderedState.isAddEnabled ? ColorToken.accent : ColorToken.inactive
        var content = cell.defaultContentConfiguration()
        content.text = String(localized: .participantsContactsButton)
        content.textProperties.color = color
        content.image = IconToken.addContact.image
        content.imageProperties.tintColor = color
        cell.contentConfiguration = content
        cell.accessibilityTraits = renderedState.isAddEnabled ? .button : [.button, .notEnabled]
    }

    private func configure(_ cell: ParticipantCardCell, forParticipant id: ParticipantID) {
        let isOrganizer = renderedState.organizer?.id == id
        let row = isOrganizer ? renderedState.organizer : renderedState.participants.first { $0.id == id }
        guard let row else { return }
        let placeholder: LocalizedStringResource = isOrganizer
            ? .participantsOrganizerPlaceholder
            : .participantDetailNamePlaceholder
        cell.configure(
            name: row.name.isBlank ? String(localized: placeholder) : row.name,
            isPlaceholder: row.name.isBlank,
            tag: isOrganizer ? String(localized: .participantsOrganizerTag) : nil,
            forbiddenReceiverNames: row.forbiddenReceiverNames,
            errorMessage: errorMessage(for: row.error)
        )
    }

    private func makeHeaderConfiguration(forSectionAt sectionIndex: Int) -> UIListContentConfiguration {
        var content = UIListContentConfiguration.groupedHeader()
        content.text = sectionIndex == 0
            ? String(localized: .participantsSectionAdd)
            : String(localized: .participantsSectionOthers)
        return content
    }

    private func makeFooterConfiguration() -> UIListContentConfiguration {
        var content = UIListContentConfiguration.groupedFooter()
        content.text = String(localized: .participantsFooterCount(renderedState.count))
        return content
    }

    // MARK: - Texts

    private func errorMessage(for error: ValidationError?) -> String? {
        switch error {
        case .duplicated: String(localized: .participantsErrorDuplicate)
        case .tooLong(let limit): String(localized: .participantsErrorNameTooLong(limit))
        default: nil
        }
    }

    private func addErrorText(for error: ParticipantsState.AddError) -> String {
        switch error {
        case .duplicate: String(localized: .participantsErrorDuplicate)
        case .limitReached: String(localized: .participantsErrorLimit(FieldLimits.maxParticipants))
        case .contactWithoutName: String(localized: .participantsErrorContactWithoutName)
        case .nameTooLong(let limit): String(localized: .participantsErrorNameTooLong(limit))
        }
    }

    // MARK: - Swipe

    private func swipeActions(at indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard
            case .participant(let id) = dataSource.itemIdentifier(for: indexPath),
            id != renderedState.organizer?.id
        else { return nil }
        let title = String(localized: .participantsActionRemove)
        let remove = UIContextualAction(style: .destructive, title: title) { [weak self] _, _, completion in
            self?.viewModel.didRemove(id)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [remove])
    }
}

// MARK: - Selection

extension ParticipantsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        switch dataSource.itemIdentifier(for: indexPath) {
        case .participant: true
        case .addFromContacts: renderedState.isAddEnabled
        case .addField, .addError, nil: false
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        switch dataSource.itemIdentifier(for: indexPath) {
        case .participant(let id): viewModel.didSelect(id)
        case .addFromContacts: viewModel.didTapAddFromContacts()
        case .addField, .addError, nil: break
        }
    }
}
