import UIKit

/// A one-pixel separator line whose thickness follows the screen scale.
@MainActor
final class HairlineView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = ColorToken.separator
        isAccessibilityElement = false
        setContentHuggingPriority(.required, for: .vertical)
        registerForTraitChanges([UITraitDisplayScale.self]) { (view: HairlineView, _) in
            view.invalidateIntrinsicContentSize()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported; HairlineView is built in code.")
    }

    override var intrinsicContentSize: CGSize {
        let scale = max(traitCollection.displayScale, 1)
        return CGSize(width: UIView.noIntrinsicMetric, height: 1 / scale)
    }
}
