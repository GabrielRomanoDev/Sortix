import UIKit

final class GroupListViewController: UIViewController {
    private let viewModel: GroupListViewModel
    private lazy var listView = GroupListView { [weak self] in
        self?.viewModel.didTapCreateGroup()
    }

    init(viewModel: GroupListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported; GroupListViewController is built in code.")
    }

    override func loadView() {
        view = listView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationItem()
        setTexts()
        viewModel.onStateChange = { [weak self] state in
            self?.render(state)
        }
        render(viewModel.state)
        viewModel.viewDidLoad()
    }

    // MARK: - Setup

    /// The title lives in the header; the bar keeps only the "About" menu.
    private func setUpNavigationItem() {
        navigationItem.applyPlainAppearance()
        navigationItem.backButtonTitle = String(localized: .groupListBackButton)
        navigationItem.leftBarButtonItem = makeAboutButton()
    }

    private func setTexts() {
        listView.headerView.setTexts(
            title: String(localized: .groupListTitle),
            subtitle: String(localized: .groupListSubtitle)
        )
        listView.addButton.accessibilityLabel = String(localized: .groupListCreateButtonAccessibilityLabel)
        listView.createButton.setTitle(String(localized: .groupListCreateButtonTitle))
    }

    private func makeAboutButton() -> UIBarButtonItem {
        let button = UIBarButtonItem(image: IconToken.about.image, menu: makeAboutMenu())
        button.accessibilityLabel = String(localized: .aboutButtonAccessibilityLabel)
        return button
    }

    private func makeAboutMenu() -> UIMenu {
        let privacy = UIAction(title: String(localized: .aboutMenuPrivacy)) { [weak self] _ in
            self?.viewModel.didTapPrivacyPolicy()
        }
        let support = UIAction(title: String(localized: .aboutMenuSupport)) { [weak self] _ in
            self?.viewModel.didTapSupport()
        }
        let version = UIAction(
            title: String(localized: .aboutMenuVersion(viewModel.appVersion)),
            attributes: .disabled
        ) { _ in }
        return UIMenu(children: [privacy, support, version])
    }

    // MARK: - Rendering

    private func render(_ state: GroupListState) {
        switch state {
        case .loading:
            listView.stateView.configuration = UIContentUnavailableConfiguration.loading()
        case .empty:
            listView.stateView.configuration = makeEmptyConfiguration()
        case .failed(let error):
            listView.stateView.configuration = makeErrorConfiguration(for: error)
        }
    }

    /// The "Criar novo grupo" button below already offers the way out, so the state has no button.
    private func makeEmptyConfiguration() -> UIContentUnavailableConfiguration {
        var configuration = UIContentUnavailableConfiguration.empty()
        configuration.image = IconToken.gift.image
        configuration.imageProperties.tintColor = ColorToken.accent
        configuration.text = String(localized: .groupListEmptyTitle)
        configuration.secondaryText = String(localized: .groupListEmptyMessage)
        return configuration
    }

    private func makeErrorConfiguration(for error: ServiceError) -> UIContentUnavailableConfiguration {
        var configuration = UIContentUnavailableConfiguration.empty()
        setErrorTexts(for: error, in: &configuration)
        configuration.button = makeFilledButton(title: String(localized: .commonActionRetry))
        configuration.buttonProperties.primaryAction = UIAction { [weak self] _ in
            self?.viewModel.didTapRetry()
        }
        return configuration
    }

    private func setErrorTexts(for error: ServiceError, in configuration: inout UIContentUnavailableConfiguration) {
        if error == .network {
            configuration.image = IconToken.networkError.image
            configuration.text = String(localized: .commonErrorNetworkTitle)
            configuration.secondaryText = String(localized: .commonErrorNetworkMessage)
        } else {
            configuration.image = IconToken.genericError.image
            configuration.text = String(localized: .groupListErrorMessage)
            configuration.secondaryText = String(localized: ErrorMessageMapper.message(for: error))
        }
    }

    private func makeFilledButton(title: String) -> UIButton.Configuration {
        var button = UIButton.Configuration.filled()
        button.title = title
        button.baseBackgroundColor = ColorToken.accent
        button.baseForegroundColor = ColorToken.onAccent
        return button
    }
}
