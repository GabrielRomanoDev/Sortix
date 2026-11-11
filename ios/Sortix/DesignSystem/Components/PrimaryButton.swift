import UIKit

/// The main action of a screen, pinned by the screen to the bottom safe area.
///
/// While `showsActivityIndicator` is on, the button shows a spinner in place of its title and
/// ignores taps, so an operation cannot be started twice.
@MainActor
final class PrimaryButton: UIButton {
    /// Shows the activity indicator and blocks taps while an operation runs.
    var showsActivityIndicator = false {
        didSet {
            guard showsActivityIndicator != oldValue else { return }
            isUserInteractionEnabled = !showsActivityIndicator
            setNeedsUpdateConfiguration()
        }
    }

    /// - Parameters:
    ///   - title: Title from the String Catalog.
    ///   - action: Called on tap. Assign it with `[weak self]`.
    init(title: String, action: @escaping @MainActor () -> Void) {
        super.init(frame: .zero)
        configuration = Self.makeConfiguration(title: title)
        addAction(UIAction { _ in action() }, for: .primaryActionTriggered)
        configurationUpdateHandler = { button in
            guard let button = button as? PrimaryButton else { return }
            button.configuration?.showsActivityIndicator = button.showsActivityIndicator
        }
        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: SizeToken.primaryButtonMinHeight)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported; PrimaryButton is built in code.")
    }

    /// Replaces the title, e.g. "Revelar quem eu tirei" becoming "Ver quem eu tirei".
    func setTitle(_ title: String) {
        configuration?.title = title
    }

    private static func makeConfiguration(title: String) -> UIButton.Configuration {
        var configuration = UIButton.Configuration.filled()
        configuration.title = title
        configuration.buttonSize = .large
        configuration.baseBackgroundColor = ColorToken.accent
        configuration.baseForegroundColor = ColorToken.onAccent
        configuration.background.cornerRadius = RadiusToken.button
        configuration.cornerStyle = .fixed
        configuration.titleLineBreakMode = .byWordWrapping
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
            var attributes = attributes
            attributes.font = TypographyToken.font(for: .headline)
            return attributes
        }
        return configuration
    }
}
