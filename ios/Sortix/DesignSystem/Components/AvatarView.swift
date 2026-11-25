import UIKit

/// A circle with the first letter of a person's name, in one of the avatar color pairs.
///
/// The circle has a fixed size, so the letter does not follow Dynamic Type: the name next to it
/// does. VoiceOver skips it, because the name is always read next to it.
@MainActor
final class AvatarView: UIView {
    private let initialLabel = UILabel()
    private let diameter: CGFloat

    /// - Parameter diameter: One of the avatar sizes in `SizeToken`.
    init(diameter: CGFloat) {
        self.diameter = diameter
        super.init(frame: .zero)
        setUpStyle()
        setUpLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported; AvatarView is built in code.")
    }

    func configure(name: String, colors: ColorToken.AvatarColors) {
        initialLabel.text = name.trimmed.first.map { String($0).uppercased() } ?? ""
        initialLabel.textColor = colors.foreground
        backgroundColor = colors.background
    }

    private func setUpStyle() {
        layer.cornerRadius = diameter / 2
        isAccessibilityElement = false
        // The letter takes about 40% of the circle, as in the design.
        initialLabel.font = .systemFont(ofSize: (diameter * 0.42).rounded(), weight: .semibold)
        initialLabel.textAlignment = .center
    }

    private func setUpLayout() {
        addSubviewsForAutoLayout(initialLabel)
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: diameter),
            heightAnchor.constraint(equalToConstant: diameter),
            initialLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            initialLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        setContentHuggingPriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .horizontal)
    }
}
