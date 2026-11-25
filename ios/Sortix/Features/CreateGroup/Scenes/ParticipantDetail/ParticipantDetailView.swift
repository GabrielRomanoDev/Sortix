import UIKit

/// The participant detail: the "Editar participante" header, an `insetGrouped` list with the name
/// and the restrictions, and "Remover participante" at the bottom (hidden for the organizer).
final class ParticipantDetailView: UIView {
    let headerView = ScreenHeaderView()
    let collectionView: UICollectionView
    let removeButton: PrimaryButton
    private lazy var removeFooterView = FooterActionView(button: removeButton)

    /// - Parameter onRemove: Called by "Remover participante". Assign it with `[weak self]`.
    init(layout: UICollectionViewLayout, onRemove: @escaping @MainActor () -> Void) {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        removeButton = PrimaryButton(title: "", image: IconToken.trash.image, style: .destructive, action: onRemove)
        super.init(frame: .zero)
        setUpCollectionView()
        setUpLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported; ParticipantDetailView is built in code.")
    }

    func setRemoveButtonHidden(_ isHidden: Bool) {
        removeFooterView.isHidden = isHidden
    }

    private func setUpCollectionView() {
        backgroundColor = ColorToken.background
        collectionView.backgroundColor = ColorToken.background
        collectionView.keyboardDismissMode = .interactive
    }

    private func setUpLayout() {
        let stack = UIStackView(arrangedSubviews: [headerView, collectionView, removeFooterView])
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
