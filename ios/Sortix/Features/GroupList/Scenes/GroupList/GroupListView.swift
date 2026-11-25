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
        let footerView = FooterActionView(button: createButton)
        let stack = UIStackView(arrangedSubviews: [headerView, stateView, footerView])
        stack.axis = .vertical
        addSubviewsForAutoLayout(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor)
        ])
    }
}
