import UIKit

final class ParticipantDetailViewController: UIViewController {
    private enum Section: Int {
        case name
        case restrictions
    }

    private enum Item: Hashable {
        case name
        case restriction(ParticipantID)
        case noOtherParticipants
    }

    private typealias NameCellRegistration = UICollectionView.CellRegistration<TextFieldListCell, Item>
    private typealias OptionCellRegistration = UICollectionView.CellRegistration<PersonSelectionCell, ParticipantID>
    private typealias ListCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item>

    private let viewModel: ParticipantDetailViewModel
    private lazy var detailView = ParticipantDetailView(
        layout: makeLayout(),
        onRemove: { [weak self] in self?.viewModel.didTapRemove() }
    )
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

    /// The title lives in the header; the bar keeps "Participantes" and "Concluir".
    private func setUpNavigationItem() {
        navigationItem.applyPlainAppearance()
        detailView.headerView.setTexts(title: String(localized: .participantDetailTitle))
        detailView.removeButton.setTitle(String(localized: .participantDetailRemove))
        let doneAction = UIAction(title: String(localized: .participantDetailDone)) { [weak self] _ in
            self?.viewModel.didTapDone()
        }
        let doneButton = UIBarButtonItem(primaryAction: doneAction)
        doneButton.style = .done
        navigationItem.rightBarButtonItem = doneButton
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
        navigationItem.rightBarButtonItem?.isEnabled = state.isDoneEnabled
        detailView.setRemoveButtonHidden(!state.canRemove)
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
        let optionCell = makeOptionCellRegistration()
        let listCell = makeListCellRegistration()
        let dataSource = UICollectionViewDiffableDataSource<Section, Item>(
            collectionView: detailView.collectionView
        ) { collectionView, indexPath, item in
            switch item {
            case .name:
                collectionView.dequeueConfiguredReusableCell(using: nameCell, for: indexPath, item: item)
            case .restriction(let receiverID):
                collectionView.dequeueConfiguredReusableCell(using: optionCell, for: indexPath, item: receiverID)
            case .noOtherParticipants:
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

    /// The check comes from the draft, not from the list's own selection: the list hides the
    /// separators next to selected cells, so cells are deselected right after a tap.
    private func makeOptionCellRegistration() -> OptionCellRegistration {
        OptionCellRegistration { [weak self] cell, _, receiverID in
            guard let option = self?.renderedState.options.first(where: { $0.receiverID == receiverID }) else {
                return
            }
            cell.configure(
                name: option.name,
                colors: ColorToken.avatarColors(at: option.colorIndex),
                isSelected: option.isSelected
            )
        }
    }

    private func makeListCellRegistration() -> ListCellRegistration {
        ListCellRegistration { cell, _, _ in
            var content = cell.defaultContentConfiguration()
            content.text = String(localized: .participantDetailRestrictionsEmpty)
            content.textProperties.color = ColorToken.textSecondary
            cell.contentConfiguration = content
        }
    }

    private func makeHeaderConfiguration(for section: Section) -> UIListContentConfiguration {
        var content = UIListContentConfiguration.groupedHeader()
        switch section {
        case .name:
            content.text = String(localized: .participantDetailSectionName)
        case .restrictions:
            content.text = String(localized: .participantDetailSectionRestrictions(displayName(for: renderedState)))
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
            content.text = restrictionsSummary(for: renderedState)
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

    /// "2 pessoas selecionadas…", or that this person can draw anyone.
    private func restrictionsSummary(for state: ParticipantDetailState) -> String? {
        guard !state.options.isEmpty else { return nil }
        let selectedCount = state.options.filter(\.isSelected).count
        if selectedCount == 0 {
            return String(localized: .participantDetailRestrictionsNone(displayName(for: state)))
        }
        return String(localized: .participantDetailRestrictionsSummary(selectedCount))
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
        case .restriction: true
        case .name, .noOtherParticipants, nil: false
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        switch dataSource.itemIdentifier(for: indexPath) {
        case .restriction(let receiverID):
            let isSelected = renderedState.options.first { $0.receiverID == receiverID }?.isSelected ?? false
            viewModel.didChangeRestriction(receiverID: receiverID, isSelected: !isSelected)
        case .name, .noOtherParticipants, nil:
            break
        }
    }
}
