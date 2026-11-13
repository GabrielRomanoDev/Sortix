import UIKit

/// Root view of the group list. The collection view joins this hierarchy once memberships are loaded.
final class GroupListView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = ColorToken.background
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported; GroupListView is built in code.")
    }
}
