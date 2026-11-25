import UIKit

/// Root view of the group list: the header with the round add button, the content area and the
/// "Criar novo grupo" button. The list of groups will take the content area once memberships load.
final class GroupListView: UIView {
    let addButton: UIButton
    let headerView: ScreenHeaderView
    let stateView = UIContentUnavailableView(configuration: .empty())
    let createButton: PrimaryButton

    /// - Parameter onCreate: Called by both create buttons. Assign it with `[weak self]`.
    init(onCreate: @escaping @MainActor () -> Void) {
        let addButton = UIButton(configuration: .filled())
        self.addButton = addButton
        headerView = ScreenHeaderView(titleFont: TypographyToken.largeTitle, accessoryView: addButton)
        createButton = PrimaryButton(title: "", image: IconToken.add.image, action: onCreate)
        super.init(frame: .zero)
        setUpAddButton(onCreate: onCreate)
        setUpLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported; GroupListView is built in code.")
    }

    // MARK: - Setup

    private func setUpAddButton(onCreate: @escaping @MainActor () -> Void) {
        var configuration = UIButton.Configuration.filled()
        configuration.image = IconToken.add.image
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(weight: .semibold)
        configuration.baseBackgroundColor = ColorToken.accent
        configuration.baseForegroundColor = ColorToken.onAccent
        configuration.cornerStyle = .capsule
        addButton.configuration = configuration
        addButton.addAction(UIAction { _ in onCreate() }, for: .primaryActionTriggered)
        NSLayoutConstraint.activate([
            addButton.widthAnchor.constraint(equalToConstant: SizeToken.minimumTouchTarget),
            addButton.heightAnchor.constraint(equalToConstant: SizeToken.minimumTouchTarget)
        ])
    }

    private func setUpLayout() {
        backgroundColor = ColorToken.background
        // `UIContentUnavailableView` keeps the height of its content, so it is centered inside a
        // plain container that takes all the space between the header and the button. Pinning it
        // to that space directly would stretch the header instead.
        let footerView = FooterActionView(button: createButton)
        let stateContainer = UIView()
        stateContainer.addSubviewsForAutoLayout(stateView)
        addSubviewsForAutoLayout(headerView, stateContainer, footerView)
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: trailingAnchor),

            stateContainer.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            stateContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            stateContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            stateContainer.bottomAnchor.constraint(equalTo: footerView.topAnchor),

            stateView.centerYAnchor.constraint(equalTo: stateContainer.centerYAnchor),
            stateView.leadingAnchor.constraint(equalTo: stateContainer.leadingAnchor),
            stateView.trailingAnchor.constraint(equalTo: stateContainer.trailingAnchor),
            stateView.topAnchor.constraint(greaterThanOrEqualTo: stateContainer.topAnchor),
            stateView.bottomAnchor.constraint(lessThanOrEqualTo: stateContainer.bottomAnchor),

            footerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor)
        ])
    }
}
