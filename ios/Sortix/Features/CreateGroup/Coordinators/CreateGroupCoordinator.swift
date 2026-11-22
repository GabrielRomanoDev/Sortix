import ContactsUI
import UIKit

/// The group creation flow, presented modally with its own navigation: rules → participants →
/// detail → review. Owns the draft and confirms the discard when the person leaves with data.
@MainActor
final class CreateGroupCoordinator: NSObject, Coordinator {
    enum Result: Equatable {
        case cancelled
    }

    var childCoordinators: [any Coordinator] = []
    /// Called once, after the modal is gone.
    var onFinish: ((Result) -> Void)?

    private let router: any NavigationRouting
    private let presentingRouter: any NavigationRouting
    private let dependencies: AppDependencies
    private let draftStore = CreateGroupDraftStore()
    /// Waits for the contact picker's answer.
    private var onContactPicked: (@MainActor (String?) -> Void)?

    /// - Parameters:
    ///   - router: The flow's own navigation, shown inside the modal.
    ///   - presentingRouter: The navigation the modal is presented from.
    init(router: any NavigationRouting, presentingRouter: any NavigationRouting, dependencies: AppDependencies) {
        self.router = router
        self.presentingRouter = presentingRouter
        self.dependencies = dependencies
    }

    func start() {
        router.setRoot(makeGroupRulesScene(), animated: false)
        router.rootViewController.presentationController?.delegate = self
        presentingRouter.present(router.rootViewController, animated: true)
    }

    // MARK: - Scenes

    private func makeGroupRulesScene() -> UIViewController {
        let viewModel = GroupRulesViewModel(
            draftStore: draftStore,
            calendar: .autoupdatingCurrent,
            locale: dependencies.locale,
            now: .now
        )
        viewModel.onNavigation = { [weak self] navigation in
            self?.handle(navigation)
        }
        return GroupRulesViewController(viewModel: viewModel)
    }

    private func makeParticipantsScene() -> UIViewController {
        let viewModel = ParticipantsViewModel(
            draftStore: draftStore,
            settingsStore: dependencies.settingsStore,
            locale: dependencies.locale
        )
        viewModel.onNavigation = { [weak self] navigation in
            self?.handle(navigation)
        }
        return ParticipantsViewController(viewModel: viewModel)
    }

    // MARK: - Navigation

    private func handle(_ navigation: GroupRulesViewModel.Navigation) {
        switch navigation {
        case .next:
            showParticipants()
        case .cancel:
            cancel()
        }
    }

    private func handle(_ navigation: ParticipantsViewModel.Navigation) {
        switch navigation {
        case .openParticipant:
            // TODO(create-group-restrictions): push the participant detail once stage 15 adds it.
            break
        case .pickContact(let onPicked):
            presentContactPicker(onPicked: onPicked)
        case .review:
            // TODO(create-group-draw-review): push the review once stage 16 adds it.
            break
        }
    }

    private func showParticipants() {
        router.push(makeParticipantsScene(), animated: true, onPop: nil)
    }

    private func presentContactPicker(onPicked: @escaping @MainActor (String?) -> Void) {
        onContactPicked = onPicked
        let picker = CNContactPickerViewController()
        picker.delegate = self
        router.present(picker, animated: true)
    }

    // MARK: - Leaving the flow

    private func cancel() {
        if draftStore.hasData {
            confirmDiscard()
        } else {
            dismissAndFinish()
        }
    }

    private func confirmDiscard() {
        let alert = UIAlertController(
            title: String(localized: .createGroupDiscardTitle),
            message: String(localized: .createGroupDiscardMessage),
            preferredStyle: .alert
        )
        let keepEditing = UIAlertAction(title: String(localized: .createGroupDiscardKeepEditing), style: .cancel)
        let discardTitle = String(localized: .createGroupDiscardConfirm)
        let discard = UIAlertAction(title: discardTitle, style: .destructive) { [weak self] _ in
            self?.dismissAndFinish()
        }
        alert.addAction(keepEditing)
        alert.addAction(discard)
        router.present(alert, animated: true)
    }

    private func dismissAndFinish() {
        presentingRouter.dismiss(animated: true) { [weak self] in
            self?.onFinish?(.cancelled)
        }
    }
}

// MARK: - Swipe down

extension CreateGroupCoordinator: UIAdaptivePresentationControllerDelegate {
    /// With data, the swipe is refused and `presentationControllerDidAttemptToDismiss` asks first.
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        !draftStore.hasData
    }

    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        confirmDiscard()
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        onFinish?(.cancelled)
    }
}

// MARK: - Contact picker

extension CreateGroupCoordinator: @preconcurrency CNContactPickerDelegate {
    /// Only the contact's name is read; nothing else is kept (BR-12).
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        let name = CNContactFormatter.string(from: contact, style: .fullName)
        onContactPicked?(name)
        onContactPicked = nil
    }

    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        onContactPicked = nil
    }
}
