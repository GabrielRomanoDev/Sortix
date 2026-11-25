import UIKit

/// Step 2 of the creation flow: the header with the progress bar, the add row, the cards and the
/// "Revisar e sortear" button. Everything above the list stays in place while it scrolls.
final class ParticipantsView: UIView {
    let headerView = ScreenHeaderView(step: (current: 2, total: CreateGroupStep.total))
    let addBar = AddParticipantBar()
    let collectionView: UICollectionView
    let reviewButton: PrimaryButton

    /// - Parameters:
    ///   - layout: Built by the ViewController, which owns the swipe actions.
    ///   - onReview: Called by the bottom button. Assign it with `[weak self]`.
    init(layout: UICollectionViewLayout, onReview: @escaping @MainActor () -> Void) {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        reviewButton = PrimaryButton(title: "", action: onReview)
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
        let stack = UIStackView(arrangedSubviews: [
            headerView,
            addBar,
            collectionView,
            FooterActionView(button: reviewButton)
        ])
        stack.axis = .vertical
        stack.setCustomSpacing(SpacingToken.xSmall, after: addBar)
        addSubviewsForAutoLayout(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor)
        ])
    }
}
