import UIKit

/// The main action of a screen, pinned by the screen to the bottom safe area.
@MainActor
final class PrimaryButton: UIButton {
    enum Style {
        /// White text on the accent color. The default.
        case filled
        /// Red text on a card background, such as "Remover participante".
        case destructive
    }

    /// Shows a spinner in place of the title and ignores taps while an operation runs.
    var showsActivityIndicator = false {
        didSet {
            configuration?.showsActivityIndicator = showsActivityIndicator
            isUserInteractionEnabled = !showsActivityIndicator
        }
    }

    /// - Parameters:
    ///   - title: Title from the String Catalog.
    ///   - image: Optional icon before the title.
    ///   - action: Called on tap. Assign it with `[weak self]`.
    init(title: String, image: UIImage? = nil, style: Style = .filled, action: @escaping @MainActor () -> Void) {
        super.init(frame: .zero)
        configuration = Self.makeConfiguration(title: title, image: image, style: style)
        addAction(UIAction { _ in action() }, for: .primaryActionTriggered)
        setUpLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported; PrimaryButton is built in code.")
    }

    func setTitle(_ title: String) {
        configuration?.title = title
    }

    private func setUpLayout() {
        heightAnchor.constraint(greaterThanOrEqualToConstant: SizeToken.primaryButtonMinHeight).isActive = true
    }

    private static func makeConfiguration(title: String, image: UIImage?, style: Style) -> UIButton.Configuration {
        var configuration = UIButton.Configuration.filled()
        configuration.title = title
        configuration.image = image
        configuration.imagePadding = SpacingToken.xSmall
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(weight: .semibold)
        configuration.buttonSize = .large
        switch style {
        case .filled:
            configuration.baseBackgroundColor = ColorToken.accent
            configuration.baseForegroundColor = ColorToken.onAccent
        case .destructive:
            configuration.baseBackgroundColor = ColorToken.surface
            configuration.baseForegroundColor = ColorToken.destructive
        }
        configuration.cornerStyle = .fixed
        configuration.background.cornerRadius = RadiusToken.button
        let font = TypographyToken.headline
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
            var attributes = attributes
            attributes.font = font
            return attributes
        }
        return configuration
    }
}
