import UIKit

final class ParticipantsViewController: UIViewController {
    /// Each person gets a section of their own, so every card has its own background and space
    /// around it.
    private typealias Section = ParticipantID
    private typealias Item = ParticipantID
    private typealias CardCellRegistration = UICollectionView.CellRegistration<ParticipantCardCell, Item>

    private let viewModel: ParticipantsViewModel
    private lazy var participantsView = ParticipantsView(
        layout: makeLayout(),
        onReview: { [weak self] in self?.viewModel.didTapReview() }
    )
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
        setUpAddBar()
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.viewDidAppear()
    }

    // MARK: - Setup

    /// The bar shows the step; the title lives in the header.
    private func setUpNavigationItem() {
        navigationItem.applyPlainAppearance()
        navigationItem.title = String(localized: .createGroupStep(2, CreateGroupStep.total))
        navigationItem.backButtonTitle = String(localized: .participantsTitle)
        participantsView.headerView.setTexts(title: String(localized: .participantsTitle))
        participantsView.reviewButton.setTitle(String(localized: .participantsNext))
    }

    private func setUpAddBar() {
        let addBar = participantsView.addBar
        addBar.setTexts(
            placeholder: String(localized: .participantsAddPlaceholder),
            accessibilityLabel: String(localized: .participantsAddAccessibilityLabel),
            addTitle: String(localized: .participantsAddButton),
            contactsLabel: String(localized: .participantsContactsButton)
        )
        addBar.onTextChange = { [weak self] text in
            self?.viewModel.didChangeNewName(text)
        }
        addBar.onAdd = { [weak self] in
            self?.viewModel.didTapAdd()
        }
        addBar.onPickContact = { [weak self] in
            self?.viewModel.didTapAddFromContacts()
        }
    }

    private func makeLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            let hasHeader = sectionIndex == 0
            var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            configuration.headerMode = hasHeader ? .supplementary : .none
            configuration.footerMode = self?.isLastSection(sectionIndex) == true ? .supplementary : .none
            configuration.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
                self?.swipeActions(at: indexPath)
            }
            let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: environment)
            section.contentInsets.top = hasHeader ? SpacingToken.xxSmall : 0
            section.contentInsets.bottom = SpacingToken.small - 2
            return section
        }
    }

    /// The last card carries the participant limits below it.
    private func isLastSection(_ sectionIndex: Int) -> Bool {
        sectionIndex == dataSource.snapshot().numberOfSections - 1
    }

    // MARK: - Rendering

    private func render(_ state: ParticipantsState) {
        let hadAddError = renderedState.addError != nil
        let previousState = renderedState
        renderedState = state
        participantsView.addBar.configure(
            text: state.newName,
            errorMessage: state.addError.map(addErrorText(for:)),
            isEnabled: state.isAddEnabled
        )
        participantsView.reviewButton.isEnabled = state.isReviewEnabled
        applySnapshot(for: state, previousState: previousState)
        updateSupplementaryViews()
        if !hadAddError && state.addError != nil {
            UIAccessibility.post(notification: .layoutChanged, argument: participantsView.addBar.errorLabel)
        }
    }

    private func applySnapshot(for state: ParticipantsState, previousState: ParticipantsState) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        let rows = people(in: state)
        for person in rows {
            snapshot.appendSections([person.id])
            snapshot.appendItems([person.id], toSection: person.id)
        }
        // Rows keep their identity, so the ones whose content changed are reloaded. A reload, unlike a
        // reconfigure, measures the card again even when the change happens while the screen is off
        // the window (coming back from the detail), so a card with a new restriction grows.
        let previousRows = Dictionary(people(in: previousState).map { ($0.id, $0) }) { first, _ in first }
        let changedIDs = rows.filter { previousRows[$0.id] != nil && previousRows[$0.id] != $0 }.map(\.id)
        snapshot.reloadItems(changedIDs)
        dataSource.apply(snapshot, animatingDifferences: view.window != nil)
    }

    /// The count changes with every name, so the visible header and footer are refreshed by hand.
    private func updateSupplementaryViews() {
        let collectionView = participantsView.collectionView
        let header = collectionView.supplementaryView(
            forElementKind: UICollectionView.elementKindSectionHeader,
            at: IndexPath(item: 0, section: 0)
        ) as? ListSectionHeaderView
        configure(header)

        let lastSection = dataSource.snapshot().numberOfSections - 1
        guard lastSection >= 0 else { return }
        let footer = collectionView.supplementaryView(
            forElementKind: UICollectionView.elementKindSectionFooter,
            at: IndexPath(item: 0, section: lastSection)
        ) as? UICollectionViewListCell
        footer?.contentConfiguration = makeFooterConfiguration()
    }

    private func people(in state: ParticipantsState) -> [ParticipantRow] {
        [state.organizer].compactMap { $0 } + state.participants
    }

    // MARK: - Data source

    private func makeDataSource() -> UICollectionViewDiffableDataSource<Section, Item> {
        let cardCell = CardCellRegistration { [weak self] cell, _, id in
            self?.configure(cell, forParticipant: id)
        }
        let dataSource = UICollectionViewDiffableDataSource<Section, Item>(
            collectionView: participantsView.collectionView
        ) { collectionView, indexPath, id in
            collectionView.dequeueConfiguredReusableCell(using: cardCell, for: indexPath, item: id)
        }
        setUpSupplementaryViews(for: dataSource)
        return dataSource
    }

    private func setUpSupplementaryViews(for dataSource: UICollectionViewDiffableDataSource<Section, Item>) {
        let header = UICollectionView.SupplementaryRegistration<ListSectionHeaderView>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { [weak self] view, _, _ in
            self?.configure(view)
        }
        let footer = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(
            elementKind: UICollectionView.elementKindSectionFooter
        ) { [weak self] view, _, _ in
            view.contentConfiguration = self?.makeFooterConfiguration()
        }
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            if kind == UICollectionView.elementKindSectionHeader {
                return collectionView.dequeueConfiguredReusableSupplementary(using: header, for: indexPath)
            }
            return collectionView.dequeueConfiguredReusableSupplementary(using: footer, for: indexPath)
        }
    }

    // MARK: - Content

    private func configure(_ header: ListSectionHeaderView?) {
        header?.configure(
            title: String(localized: .participantsHeaderCount(renderedState.count)),
            detail: String(localized: .participantsHeaderHint)
        )
    }

    private func makeFooterConfiguration() -> UIListContentConfiguration {
        var content = UIListContentConfiguration.groupedFooter()
        content.text = String(localized: .participantsFooterLimits(
            FieldLimits.minParticipants,
            FieldLimits.maxParticipants
        ))
        return content
    }

    private func configure(_ cell: ParticipantCardCell, forParticipant id: ParticipantID) {
        let isOrganizer = renderedState.organizer?.id == id
        let row = isOrganizer ? renderedState.organizer : renderedState.participants.first { $0.id == id }
        guard let row else { return }
        cell.configure(
            name: row.name.isBlank ? String(localized: .participantsOrganizerPlaceholder) : row.name,
            isPlaceholder: row.name.isBlank,
            tag: isOrganizer ? String(localized: .participantsOrganizerTag) : nil,
            colors: ColorToken.avatarColors(at: row.colorIndex),
            restrictionsTitle: String(localized: .participantsRestrictionsTitle),
            forbiddenReceivers: row.forbiddenReceivers.map { receiver in
                (name: receiver.name, colors: ColorToken.avatarColors(at: receiver.colorIndex))
            },
            errorMessage: errorMessage(for: row.error)
        )
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
        guard let id = dataSource.itemIdentifier(for: indexPath), id != renderedState.organizer?.id else {
            return nil
        }
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
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let id = dataSource.itemIdentifier(for: indexPath) else { return }
        viewModel.didSelect(id)
    }
}
