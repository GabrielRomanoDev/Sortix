import UIKit

/// The participants list: an `insetGrouped` collection view that stays above the keyboard.
final class ParticipantsView: UIView {
    let collectionView: UICollectionView

    /// - Parameter layout: Built by the ViewController, which owns the swipe actions.
    init(layout: UICollectionViewLayout) {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(frame: .zero)
        setUpCollectionView()
        setUpLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported; ParticipantsView is built in code.")
    }

    private func setUpCollectionView() {
        backgroundColor = ColorToken.background
        collectionView.backgroundColor = ColorToken.background
        collectionView.keyboardDismissMode = .interactive
        // Cards grow when restrictions are added, without reloading them.
        collectionView.selfSizingInvalidation = .enabledIncludingConstraints
    }

    private func setUpLayout() {
        addSubviewsForAutoLayout(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor)
        ])
    }
}
