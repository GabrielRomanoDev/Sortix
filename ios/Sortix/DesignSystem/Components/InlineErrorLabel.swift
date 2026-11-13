import UIKit

/// Validation message shown below a field. Hidden while there is no message.
///
/// The screen that sets a message is responsible for posting `.layoutChanged` so VoiceOver reads it.
@MainActor
final class InlineErrorLabel: UILabel {
    /// The message to display, or `nil` to hide the label.
    var message: String? {
        didSet {
            text = message
            isHidden = message == nil
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpStyle()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported; InlineErrorLabel is built in code.")
    }

    private func setUpStyle() {
        font = TypographyToken.footnote
        textColor = ColorToken.destructive
        adjustsFontForContentSizeCategory = true
        numberOfLines = 0
        isHidden = true
    }
}
