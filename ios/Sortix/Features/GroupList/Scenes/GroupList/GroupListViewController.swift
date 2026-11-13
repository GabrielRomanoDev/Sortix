import UIKit

final class GroupListViewController: UIViewController {
    private let viewModel: GroupListViewModel

    init(viewModel: GroupListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported; GroupListViewController is built in code.")
    }

    override func loadView() {
        view = GroupListView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationItem()
        viewModel.onStateChange = { [weak self] state in
            self?.render(state)
        }
        render(viewModel.state)
        viewModel.viewDidLoad()
    }

    // MARK: - Setup

    private func setUpNavigationItem() {
        title = String(localized: .groupListTitle)
        navigationItem.largeTitleDisplayMode = .always

        let createAction = UIAction { [weak self] _ in
            self?.viewModel.didTapCreateGroup()
        }
        let createButton = UIBarButtonItem(systemItem: .add, primaryAction: createAction)
        createButton.accessibilityLabel = String(localized: .groupListCreateButtonAccessibilityLabel)
        navigationItem.rightBarButtonItem = createButton
    }

    // MARK: - Rendering

    private func render(_ state: GroupListState) {
        switch state {
        case .loading:
            contentUnavailableConfiguration = UIContentUnavailableConfiguration.loading()
        case .empty:
            contentUnavailableConfiguration = makeEmptyConfiguration()
        }
    }

    private func makeEmptyConfiguration() -> UIContentUnavailableConfiguration {
        var configuration = UIContentUnavailableConfiguration.empty()
        configuration.image = IconToken.gift.image
        configuration.text = String(localized: .groupListEmptyTitle)
        configuration.secondaryText = String(localized: .groupListEmptyMessage)

        var button = UIButton.Configuration.filled()
        button.title = String(localized: .groupListEmptyAction)
        button.baseBackgroundColor = ColorToken.accent
        button.baseForegroundColor = ColorToken.onAccent
        configuration.button = button
        configuration.buttonProperties.primaryAction = UIAction { [weak self] _ in
            self?.viewModel.didTapCreateGroup()
        }
        return configuration
    }
}
