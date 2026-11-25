import UIKit

/// The segmented bar at the top of the creation flow: one segment per step, filled up to the
/// current one. VoiceOver skips it; the navigation bar already reads "Etapa 1 de 3".
@MainActor
final class StepProgressView: UIView {
    private let stack = UIStackView()

    /// - Parameters:
    ///   - current: The current step, starting at 1.
    ///   - total: Number of steps in the flow.
    init(current: Int, total: Int) {
        super.init(frame: .zero)
        isAccessibilityElement = false
        setUpSegments(current: current, total: total)
        setUpLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported; StepProgressView is built in code.")
    }

    private func setUpSegments(current: Int, total: Int) {
        for step in 1...max(total, 1) {
            let segment = UIView()
            segment.backgroundColor = step <= current ? ColorToken.accent : ColorToken.inactive
            segment.layer.cornerRadius = SizeToken.progressBarHeight / 2
            stack.addArrangedSubview(segment)
        }
    }

    private func setUpLayout() {
        stack.distribution = .fillEqually
        stack.spacing = SpacingToken.xSmall - 2
        addSubviewsForAutoLayout(stack)
        NSLayoutConstraint.activate(stack.constraintsPinningEdges(to: self) + [
            heightAnchor.constraint(equalToConstant: SizeToken.progressBarHeight)
        ])
    }
}
