import UIKit

/// The popup shown the first time the participants screen opens: an example participant with two
/// restrictions and how to add them. Present it with `.overFullScreen` and `.crossDissolve`.
///
/// It has no ViewModel: it only shows fixed texts and reports the tap on "Entendido".
final class RestrictionsTipViewController: UIViewController {
    private let onConfirm: @MainActor () -> Void
    private let tipView: RestrictionsTipView

    /// - Parameter onConfirm: Called on "Entendido". The caller dismisses the popup.
    init(onConfirm: @escaping @MainActor () -> Void) {
        self.onConfirm = onConfirm
        tipView = RestrictionsTipView(onConfirm: onConfirm)
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported; RestrictionsTipViewController is built in code.")
    }

    override func loadView() {
        view = tipView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tipView.setTexts(
            exampleGiver: String(localized: .restrictionsTipExampleGiver),
            exampleReceivers: [
                String(localized: .restrictionsTipExampleFirstReceiver),
                String(localized: .restrictionsTipExampleSecondReceiver)
            ],
            restrictionsTitle: String(localized: .participantsRestrictionsTitle),
            caption: String(localized: .restrictionsTipExampleCaption),
            title: String(localized: .restrictionsTipTitle),
            message: String(localized: .restrictionsTipMessage),
            confirm: String(localized: .restrictionsTipConfirm)
        )
    }

    /// The two-finger scrub closes the popup like "Entendido".
    override func accessibilityPerformEscape() -> Bool {
        onConfirm()
        return true
    }
}
