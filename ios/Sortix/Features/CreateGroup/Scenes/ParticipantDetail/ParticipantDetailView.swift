import UIKit

/// The detail list: an `insetGrouped` collection view. Restriction checkmarks come from the state.
final class ParticipantDetailView: UIView {
    let collectionView: UICollectionView

    init(layout: UICollectionViewLayout) {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(frame: .zero)
        setUpCollectionView()
        setUpLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported; ParticipantDetailView is built in code.")
    }

    private func setUpCollectionView() {
        backgroundColor = ColorToken.background
        collectionView.backgroundColor = ColorToken.background
        collectionView.keyboardDismissMode = .interactive
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
