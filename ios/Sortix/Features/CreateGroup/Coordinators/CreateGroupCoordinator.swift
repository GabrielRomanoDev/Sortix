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

    // MARK: - Navigation

    private func handle(_ navigation: GroupRulesViewModel.Navigation) {
        switch navigation {
        case .next:
            showParticipants()
        case .cancel:
            cancel()
        }
    }

    private func showParticipants() {
        // TODO(create-group-participants): push the participants scene once stage 14 adds it.
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
