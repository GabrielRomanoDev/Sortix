import UIKit

final class ParticipantsViewController: UIViewController {
    private enum Section: Int {
        case organizer
        case others
    }

    private enum Item: Hashable {
        case participant(ParticipantID)
        case addField
        case addFromContacts
    }

    private typealias ParticipantCellRegistration =
        UICollectionView.CellRegistration<UICollectionViewListCell, ParticipantID>
    private typealias AddFieldCellRegistration = UICollectionView.CellRegistration<TextFieldListCell, Item>
    private typealias ContactsCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item>

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
        var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        configuration.headerMode = .supplementary
        configuration.footerMode = .supplementary
        configuration.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            self?.swipeActions(at: indexPath)
        }
        return UICollectionViewCompositionalLayout.list(using: configuration)
    }

    // MARK: - Rendering

    private func render(_ state: ParticipantsState) {
        renderedState = state
        navigationItem.rightBarButtonItem?.isEnabled = state.isReviewEnabled
        applySnapshot(for: state)
        updateFooter()
    }

    private func applySnapshot(for state: ParticipantsState) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.organizer, .others])
        if let organizer = state.organizer {
            snapshot.appendItems([.participant(organizer.id)], toSection: .organizer)
        }
        snapshot.appendItems([.addField, .addFromContacts], toSection: .others)
        snapshot.appendItems(state.participants.map { .participant($0.id) }, toSection: .others)
        // Rows keep their identity, so their content is refreshed explicitly.
        snapshot.reconfigureItems(snapshot.itemIdentifiers)
        dataSource.apply(snapshot, animatingDifferences: view.window != nil)
    }

    private func updateFooter() {
        let indexPath = IndexPath(item: 0, section: Section.others.rawValue)
        let footer = participantsView.collectionView.supplementaryView(
            forElementKind: UICollectionView.elementKindSectionFooter,
            at: indexPath
        ) as? UICollectionViewListCell
        footer?.contentConfiguration = makeFooterConfiguration(for: .others)
    }

    // MARK: - Data source

    private func makeDataSource() -> UICollectionViewDiffableDataSource<Section, Item> {
        let participantCell = makeParticipantCellRegistration()
        let addFieldCell = makeAddFieldCellRegistration()
        let contactsCell = makeContactsCellRegistration()
        let dataSource = UICollectionViewDiffableDataSource<Section, Item>(
            collectionView: participantsView.collectionView
        ) { collectionView, indexPath, item in
            switch item {
            case .participant(let id):
                collectionView.dequeueConfiguredReusableCell(using: participantCell, for: indexPath, item: id)
            case .addField:
                collectionView.dequeueConfiguredReusableCell(using: addFieldCell, for: indexPath, item: item)
            case .addFromContacts:
                collectionView.dequeueConfiguredReusableCell(using: contactsCell, for: indexPath, item: item)
            }
        }
        setUpSupplementaryViews(for: dataSource)
        return dataSource
    }

    private func setUpSupplementaryViews(for dataSource: UICollectionViewDiffableDataSource<Section, Item>) {
        let header = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { [weak self] view, _, indexPath in
            view.contentConfiguration = self?.makeHeaderConfiguration(for: Section(rawValue: indexPath.section))
        }
        let footer = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(
            elementKind: UICollectionView.elementKindSectionFooter
        ) { [weak self] view, _, indexPath in
            view.contentConfiguration = self?.makeFooterConfiguration(for: Section(rawValue: indexPath.section))
        }
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            let registration = kind == UICollectionView.elementKindSectionHeader ? header : footer
            return collectionView.dequeueConfiguredReusableSupplementary(using: registration, for: indexPath)
        }
    }

    // MARK: - Cells

    private func makeParticipantCellRegistration() -> ParticipantCellRegistration {
        UICollectionView.CellRegistration { [weak self] cell, _, id in
            self?.configure(cell, forParticipant: id)
        }
    }

    private func makeAddFieldCellRegistration() -> AddFieldCellRegistration {
        UICollectionView.CellRegistration { [weak self] cell, _, _ in
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

    private func makeContactsCellRegistration() -> ContactsCellRegistration {
        UICollectionView.CellRegistration { [weak self] cell, _, _ in
            guard let self else { return }
            let color = renderedState.isAddEnabled ? ColorToken.accent : ColorToken.inactive
            var content = cell.defaultContentConfiguration()
            content.text = String(localized: .participantsContactsButton)
            content.textProperties.color = color
            content.image = IconToken.addContact.image
            content.imageProperties.tintColor = color
            cell.contentConfiguration = content
            cell.accessibilityTraits = renderedState.isAddEnabled ? .button : [.button, .notEnabled]
        }
    }

    private func configure(_ cell: UICollectionViewListCell, forParticipant id: ParticipantID) {
        let isOrganizer = renderedState.organizer?.id == id
        let row = isOrganizer ? renderedState.organizer : renderedState.participants.first { $0.id == id }
        guard let row else { return }

        var content = UIListContentConfiguration.subtitleCell()
        content.text = row.name.isEmpty ? String(localized: .participantsOrganizerPlaceholder) : row.name
        content.textProperties.color = row.name.isEmpty ? ColorToken.textSecondary : ColorToken.textPrimary
        content.secondaryText = errorMessage(for: row.error) ?? restrictionsSummary(for: row)
        content.secondaryTextProperties.color = row.error == nil ? ColorToken.textSecondary : ColorToken.destructive
        cell.contentConfiguration = content

        let tag = String(localized: .participantsOrganizerTag)
        cell.accessories = isOrganizer ? [.label(text: tag), .disclosureIndicator()] : [.disclosureIndicator()]
        let label = [content.text, isOrganizer ? tag : nil, content.secondaryText].compactMap { $0 }
        cell.accessibilityLabel = label.joined(separator: ", ")
    }

    private func makeHeaderConfiguration(for section: Section?) -> UIListContentConfiguration {
        var content = UIListContentConfiguration.groupedHeader()
        switch section {
        case .organizer: content.text = String(localized: .participantsSectionYou)
        case .others: content.text = String(localized: .participantsSectionOthers)
        case nil: break
        }
        return content
    }

    private func makeFooterConfiguration(for section: Section?) -> UIListContentConfiguration {
        var content = UIListContentConfiguration.groupedFooter()
        guard section == .others else { return content }
        content.text = footerText(for: renderedState.footer)
        content.textProperties.color = renderedState.footer.isError ? ColorToken.destructive : ColorToken.textSecondary
        return content
    }

    // MARK: - Texts

    private func restrictionsSummary(for row: ParticipantRow) -> String {
        if row.restrictedGiverNames.isEmpty {
            return String(localized: .participantsRestrictionsNone)
        }
        let names = row.restrictedGiverNames.formatted(.list(type: .and).locale(viewModel.locale))
        return String(localized: .participantsRestrictionsSummary(names))
    }

    private func errorMessage(for error: ValidationError?) -> String? {
        switch error {
        case .duplicated: String(localized: .participantsErrorDuplicate)
        case .tooLong(let limit): String(localized: .participantsErrorNameTooLong(limit))
        default: nil
        }
    }

    private func footerText(for footer: ParticipantsState.Footer) -> String {
        switch footer {
        case .count(let count): String(localized: .participantsFooterCount(count))
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
        case .addField, nil: false
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        switch dataSource.itemIdentifier(for: indexPath) {
        case .participant(let id): viewModel.didSelect(id)
        case .addFromContacts: viewModel.didTapAddFromContacts()
        case .addField, nil: break
        }
    }
}
