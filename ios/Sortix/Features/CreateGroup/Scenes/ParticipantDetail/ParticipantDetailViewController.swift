import UIKit

final class ParticipantDetailViewController: UIViewController {
    private enum Section: Int {
        case name
        case restrictions
        case remove
    }

    private enum Item: Hashable {
        case name
        case restriction(ParticipantID)
        case noOtherParticipants
        case remove
    }

    private typealias NameCellRegistration = UICollectionView.CellRegistration<TextFieldListCell, Item>
    private typealias ListCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item>

    private let viewModel: ParticipantDetailViewModel
    private lazy var detailView = ParticipantDetailView(layout: makeLayout())
    private lazy var dataSource = makeDataSource()
    /// The last state shown. Cells read their content from it.
    private var renderedState = ParticipantDetailState()

    init(viewModel: ParticipantDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported; ParticipantDetailViewController is built in code.")
    }

    override func loadView() {
        view = detailView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationItem()
        detailView.collectionView.delegate = self
        viewModel.onStateChange = { [weak self] state in
            self?.render(state)
        }
        render(viewModel.state)
        viewModel.viewDidLoad()
    }

    // MARK: - Setup

    private func setUpNavigationItem() {
        navigationItem.largeTitleDisplayMode = .never
        let doneAction = UIAction(title: String(localized: .commonActionDone)) { [weak self] _ in
            self?.viewModel.didTapDone()
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(primaryAction: doneAction)
    }

    private func makeLayout() -> UICollectionViewLayout {
        var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        configuration.headerMode = .supplementary
        configuration.footerMode = .supplementary
        return UICollectionViewCompositionalLayout.list(using: configuration)
    }

    // MARK: - Rendering

    private func render(_ state: ParticipantDetailState) {
        renderedState = state
        title = displayName(for: state)
        navigationItem.rightBarButtonItem?.isEnabled = state.isDoneEnabled
        applySnapshot(for: state)
        updateSupplementaryViews()
    }

    private func applySnapshot(for state: ParticipantDetailState) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.name, .restrictions])
        snapshot.appendItems([.name], toSection: .name)
        if state.options.isEmpty {
            snapshot.appendItems([.noOtherParticipants], toSection: .restrictions)
        } else {
            snapshot.appendItems(state.options.map { .restriction($0.receiverID) }, toSection: .restrictions)
        }
        if state.canRemove {
            snapshot.appendSections([.remove])
            snapshot.appendItems([.remove], toSection: .remove)
        }
        snapshot.reconfigureItems(snapshot.itemIdentifiers)
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    /// Headers and footers change with the name, so the visible ones are refreshed by hand.
    private func updateSupplementaryViews() {
        let collectionView = detailView.collectionView
        for section in dataSource.snapshot().sectionIdentifiers {
            let indexPath = IndexPath(item: 0, section: section.rawValue)
            let header = collectionView.supplementaryView(
                forElementKind: UICollectionView.elementKindSectionHeader,
                at: indexPath
            ) as? UICollectionViewListCell
            header?.contentConfiguration = makeHeaderConfiguration(for: section)
            let footer = collectionView.supplementaryView(
                forElementKind: UICollectionView.elementKindSectionFooter,
                at: indexPath
            ) as? UICollectionViewListCell
            footer?.contentConfiguration = makeFooterConfiguration(for: section)
        }
    }

    // MARK: - Data source

    private func makeDataSource() -> UICollectionViewDiffableDataSource<Section, Item> {
        let nameCell = makeNameCellRegistration()
        let listCell = makeListCellRegistration()
        let dataSource = UICollectionViewDiffableDataSource<Section, Item>(
            collectionView: detailView.collectionView
        ) { collectionView, indexPath, item in
            switch item {
            case .name:
                collectionView.dequeueConfiguredReusableCell(using: nameCell, for: indexPath, item: item)
            case .restriction, .noOtherParticipants, .remove:
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
            guard let section = Section(rawValue: indexPath.section) else { return }
            view.contentConfiguration = self?.makeHeaderConfiguration(for: section)
        }
        let footer = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(
            elementKind: UICollectionView.elementKindSectionFooter
        ) { [weak self] view, _, indexPath in
            guard let section = Section(rawValue: indexPath.section) else { return }
            view.contentConfiguration = self?.makeFooterConfiguration(for: section)
        }
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            let registration = kind == UICollectionView.elementKindSectionHeader ? header : footer
            return collectionView.dequeueConfiguredReusableSupplementary(using: registration, for: indexPath)
        }
    }

    // MARK: - Cells

    private func makeNameCellRegistration() -> NameCellRegistration {
        NameCellRegistration { [weak self] cell, _, _ in
            guard let self else { return }
            let placeholder: LocalizedStringResource = renderedState.isOrganizer
                ? .participantDetailOrganizerNamePlaceholder
                : .participantDetailNamePlaceholder
            cell.configure(
                text: renderedState.name,
                placeholder: String(localized: placeholder),
                accessibilityLabel: String(localized: .participantDetailSectionName),
                returnKeyType: .done
            )
            cell.textField.autocapitalizationType = .words
            cell.onTextChange = { [weak self] text in
                self?.viewModel.didChangeName(text)
            }
            cell.onReturn = { [weak self] in
                self?.viewModel.didTapDone()
            }
        }
    }

    private func makeListCellRegistration() -> ListCellRegistration {
        ListCellRegistration { [weak self] cell, _, item in
            guard let self else { return }
            var content = cell.defaultContentConfiguration()
            switch item {
            case .restriction(let receiverID):
                let option = renderedState.options.first { $0.receiverID == receiverID }
                let isSelected = option?.isSelected ?? false
                content.text = option?.name
                cell.accessories = isSelected ? [.checkmark()] : []
                cell.accessibilityTraits = isSelected ? [.button, .selected] : [.button]
            case .noOtherParticipants, .name:
                content.text = String(localized: .participantDetailRestrictionsEmpty)
                content.textProperties.color = ColorToken.textSecondary
                cell.accessories = []
                cell.accessibilityTraits = []
            case .remove:
                content.text = String(localized: .participantDetailRemove)
                content.textProperties.color = ColorToken.destructive
                content.textProperties.alignment = .center
                cell.accessories = []
                cell.accessibilityTraits = [.button]
            }
            cell.contentConfiguration = content
            // The checkmark comes from the draft, not from the native selection: the list hides
            // the separators next to selected cells, so cells are deselected right after a tap.
            var background = UIBackgroundConfiguration.listGroupedCell()
            background.backgroundColor = ColorToken.surface
            cell.backgroundConfiguration = background
        }
    }

    private func makeHeaderConfiguration(for section: Section) -> UIListContentConfiguration {
        var content = UIListContentConfiguration.groupedHeader()
        switch section {
        case .name:
            content.text = String(localized: .participantDetailSectionName)
        case .restrictions:
            content.text = String(localized: .participantDetailSectionRestrictions(displayName(for: renderedState)))
        case .remove:
            content.text = nil
        }
        return content
    }

    private func makeFooterConfiguration(for section: Section) -> UIListContentConfiguration {
        var content = UIListContentConfiguration.groupedFooter()
        switch section {
        case .name:
            content.text = nameErrorMessage(for: renderedState.nameError)
            content.textProperties.color = ColorToken.destructive
        case .restrictions:
            content.text = String(localized: .participantDetailRestrictionsFooter)
        case .remove:
            content.text = nil
        }
        return content
    }

    // MARK: - Texts

    private func displayName(for state: ParticipantDetailState) -> String {
        if !state.name.isBlank {
            return state.name.trimmed
        }
        let placeholder: LocalizedStringResource = state.isOrganizer
            ? .participantDetailOrganizerNamePlaceholder
            : .participantDetailNamePlaceholder
        return String(localized: placeholder)
    }

    private func nameErrorMessage(for error: ValidationError?) -> String? {
        switch error {
        case .duplicated: String(localized: .participantsErrorDuplicate)
        case .tooLong(let limit): String(localized: .participantsErrorNameTooLong(limit))
        default: nil
        }
    }
}

// MARK: - Selection

extension ParticipantDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        switch dataSource.itemIdentifier(for: indexPath) {
        case .restriction, .remove: true
        case .name, .noOtherParticipants, nil: false
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        switch dataSource.itemIdentifier(for: indexPath) {
        case .restriction(let receiverID):
            let isSelected = renderedState.options.first { $0.receiverID == receiverID }?.isSelected ?? false
            viewModel.didChangeRestriction(receiverID: receiverID, isSelected: !isSelected)
        case .remove:
            viewModel.didTapRemove()
        case .name, .noOtherParticipants, nil:
            break
        }
    }
}
