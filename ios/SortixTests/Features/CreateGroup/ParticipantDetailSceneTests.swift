import Testing
@testable import Sortix
import UIKit

@MainActor
struct ParticipantDetailSceneTests {
    private let organizer = ParticipantDraft(id: ParticipantID(rawValue: "org"), name: "", isOrganizer: true)
    private let ana = ParticipantDraft(id: ParticipantID(rawValue: "ana"), name: "Ana", isOrganizer: false)
    private let bruno = ParticipantDraft(id: ParticipantID(rawValue: "bruno"), name: "Bruno", isOrganizer: false)

    private func makeStore() -> CreateGroupDraftStore {
        let store = CreateGroupDraftStore()
        store.draft.participants = [organizer, ana, bruno]
        return store
    }

    private func makeViewModel(
        editing id: ParticipantID,
        store: CreateGroupDraftStore,
        settingsStore: MockSettingsStore = MockSettingsStore()
    ) -> ParticipantDetailViewModel {
        ParticipantDetailViewModel(participantID: id, draftStore: store, settingsStore: settingsStore)
    }

    @Test func sceneIsReleased() {
        expectDeallocation {
            let viewModel = makeViewModel(editing: ana.id, store: makeStore())
            let viewController = ParticipantDetailViewController(viewModel: viewModel)
            viewController.loadViewIfNeeded()
            return [viewController, viewModel]
        }
    }

    @Test func listsEveryoneElseAsOptions() {
        let viewModel = makeViewModel(editing: ana.id, store: makeStore())

        viewModel.viewDidLoad()

        #expect(viewModel.state.options.map(\.receiverID) == [organizer.id, bruno.id])
        #expect(viewModel.state.options.allSatisfy { !$0.isSelected })
    }

    @Test func restrictionsAreOneWay() throws {
        let store = makeStore()
        let viewModel = makeViewModel(editing: ana.id, store: store)
        viewModel.viewDidLoad()

        viewModel.didChangeRestriction(receiverID: bruno.id, isSelected: true)

        // "Ana cannot draw Bruno" is stored on Bruno, the one who would be drawn.
        let savedAna = try #require(store.draft.participants.first { $0.id == ana.id })
        let savedBruno = try #require(store.draft.participants.first { $0.id == bruno.id })
        #expect(savedBruno.forbiddenGiverIDs == [ana.id])
        #expect(savedAna.forbiddenGiverIDs.isEmpty)
        #expect(viewModel.state.options.last?.isSelected == true)
    }

    @Test func unselectingRemovesTheRestriction() throws {
        let store = makeStore()
        let viewModel = makeViewModel(editing: ana.id, store: store)
        viewModel.viewDidLoad()

        viewModel.didChangeRestriction(receiverID: bruno.id, isSelected: true)
        viewModel.didChangeRestriction(receiverID: bruno.id, isSelected: false)

        let savedBruno = try #require(store.draft.participants.first { $0.id == bruno.id })
        #expect(savedBruno.forbiddenGiverIDs.isEmpty)
    }

    @Test func duplicatedNameDisablesDone() {
        let viewModel = makeViewModel(editing: ana.id, store: makeStore())
        var events: [ParticipantDetailViewModel.Navigation] = []
        viewModel.onNavigation = { events.append($0) }
        viewModel.viewDidLoad()

        viewModel.didChangeName("bruno")
        viewModel.didTapDone()

        #expect(viewModel.state.nameError == .duplicated)
        #expect(viewModel.state.isDoneEnabled == false)
        #expect(events.isEmpty)
    }

    @Test func emptyOrganizerNameDisablesDoneWithoutAnError() {
        let viewModel = makeViewModel(editing: organizer.id, store: makeStore())

        viewModel.viewDidLoad()

        #expect(viewModel.state.nameError == nil)
        #expect(viewModel.state.isDoneEnabled == false)
    }

    @Test func validOrganizerNameIsRememberedForNextTime() {
        let settingsStore = MockSettingsStore()
        let viewModel = makeViewModel(editing: organizer.id, store: makeStore(), settingsStore: settingsStore)
        viewModel.viewDidLoad()

        viewModel.didChangeName(" Carla ")

        #expect(settingsStore.lastOrganizerName == "Carla")
        #expect(viewModel.state.isDoneEnabled)
    }

    @Test func otherParticipantNamesAreNotRemembered() {
        let settingsStore = MockSettingsStore()
        let viewModel = makeViewModel(editing: ana.id, store: makeStore(), settingsStore: settingsStore)
        viewModel.viewDidLoad()

        viewModel.didChangeName("Ana Paula")

        #expect(settingsStore.lastOrganizerName == nil)
    }

    @Test func doneEmitsNavigationWhenValid() {
        let viewModel = makeViewModel(editing: ana.id, store: makeStore())
        var events: [ParticipantDetailViewModel.Navigation] = []
        viewModel.onNavigation = { events.append($0) }
        viewModel.viewDidLoad()

        viewModel.didTapDone()

        #expect(events == [.done])
    }

    @Test func removingAParticipantClearsTheirRestrictionsAndLeaves() throws {
        let store = makeStore()
        store.draft.participants[2].forbiddenGiverIDs = [ana.id]
        let viewModel = makeViewModel(editing: ana.id, store: store)
        var events: [ParticipantDetailViewModel.Navigation] = []
        viewModel.onNavigation = { events.append($0) }
        viewModel.viewDidLoad()

        viewModel.didTapRemove()

        #expect(store.draft.participants.map(\.id) == [organizer.id, bruno.id])
        #expect(store.draft.participants.allSatisfy { $0.forbiddenGiverIDs.isEmpty })
        #expect(events == [.removed])
    }

    @Test func organizerCannotBeRemoved() {
        let store = makeStore()
        let viewModel = makeViewModel(editing: organizer.id, store: store)
        var events: [ParticipantDetailViewModel.Navigation] = []
        viewModel.onNavigation = { events.append($0) }
        viewModel.viewDidLoad()

        viewModel.didTapRemove()

        #expect(viewModel.state.canRemove == false)
        #expect(store.draft.participants.count == 3)
        #expect(events.isEmpty)
    }
}
