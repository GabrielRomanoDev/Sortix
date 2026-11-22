import Foundation
import Testing
@testable import Sortix
import UIKit

@MainActor
struct ParticipantsSceneTests {
    private func makeViewModel(
        store: CreateGroupDraftStore = CreateGroupDraftStore(),
        settingsStore: MockSettingsStore = MockSettingsStore()
    ) -> ParticipantsViewModel {
        ParticipantsViewModel(draftStore: store, settingsStore: settingsStore, locale: Locale(identifier: "pt_BR"))
    }

    private func add(_ name: String, to viewModel: ParticipantsViewModel) {
        viewModel.didChangeNewName(name)
        viewModel.didTapAdd()
    }

    @Test func sceneIsReleased() {
        expectDeallocation {
            let viewModel = makeViewModel()
            let viewController = ParticipantsViewController(viewModel: viewModel)
            viewController.loadViewIfNeeded()
            return [viewController, viewModel]
        }
    }

    @Test func organizerComesFirstWithTheLastNameUsed() {
        let store = CreateGroupDraftStore()
        let settingsStore = MockSettingsStore()
        settingsStore.lastOrganizerName = "Carla"
        let viewModel = makeViewModel(store: store, settingsStore: settingsStore)

        viewModel.viewDidLoad()

        #expect(viewModel.state.organizer?.name == "Carla")
        #expect(store.draft.participants.first?.isOrganizer == true)
    }

    @Test func organizerIsAddedOnlyOnce() {
        let store = CreateGroupDraftStore()
        makeViewModel(store: store).viewDidLoad()
        makeViewModel(store: store).viewDidLoad()

        #expect(store.draft.participants.filter(\.isOrganizer).count == 1)
    }

    @Test func addingClearsTheFieldAndUpdatesTheCount() {
        let viewModel = makeViewModel()
        viewModel.viewDidLoad()

        add("  Ana ", to: viewModel)

        #expect(viewModel.state.participants.map(\.name) == ["Ana"])
        #expect(viewModel.state.newName.isEmpty)
        #expect(viewModel.state.footer == .count(2))
    }

    @Test func duplicatedNameIsNotAdded() {
        let viewModel = makeViewModel()
        viewModel.viewDidLoad()

        add("Ana", to: viewModel)
        add("aná", to: viewModel)

        #expect(viewModel.state.participants.count == 1)
        #expect(viewModel.state.footer == .duplicate)
        #expect(viewModel.state.newName == "aná")
    }

    @Test func typedNameAboveTheLimitIsNotAdded() {
        let viewModel = makeViewModel()
        viewModel.viewDidLoad()

        add(String(repeating: "a", count: FieldLimits.participantName + 1), to: viewModel)

        #expect(viewModel.state.participants.isEmpty)
        #expect(viewModel.state.footer == .nameTooLong(limit: FieldLimits.participantName))
    }

    @Test func reviewNeedsThreeValidParticipants() {
        let settingsStore = MockSettingsStore()
        settingsStore.lastOrganizerName = "Carla"
        let viewModel = makeViewModel(settingsStore: settingsStore)
        viewModel.viewDidLoad()

        add("Ana", to: viewModel)
        #expect(viewModel.state.isReviewEnabled == false)

        add("Bruno", to: viewModel)
        #expect(viewModel.state.isReviewEnabled)
    }

    @Test func reviewWaitsForTheOrganizerName() {
        let viewModel = makeViewModel()
        viewModel.viewDidLoad()

        add("Ana", to: viewModel)
        add("Bruno", to: viewModel)

        #expect(viewModel.state.organizer?.error == nil)
        #expect(viewModel.state.isReviewEnabled == false)
    }

    @Test func removingAParticipantRemovesTheirRestrictions() throws {
        let store = CreateGroupDraftStore()
        let viewModel = makeViewModel(store: store)
        viewModel.viewDidLoad()
        add("Ana", to: viewModel)
        add("Bruno", to: viewModel)
        let ana = try #require(store.draft.participants.first { $0.name == "Ana" })
        store.draft.participants[2].forbiddenGiverIDs = [ana.id]

        viewModel.didRemove(ana.id)

        #expect(store.draft.participants.map(\.name).contains("Ana") == false)
        #expect(store.draft.participants.allSatisfy { $0.forbiddenGiverIDs.isEmpty })
    }

    @Test func organizerCannotBeRemoved() throws {
        let store = CreateGroupDraftStore()
        let viewModel = makeViewModel(store: store)
        viewModel.viewDidLoad()
        let organizer = try #require(viewModel.state.organizer)

        viewModel.didRemove(organizer.id)

        #expect(viewModel.state.organizer?.id == organizer.id)
    }

    @Test func restrictionsAreListedOnTheRow() throws {
        let store = CreateGroupDraftStore()
        let viewModel = makeViewModel(store: store)
        viewModel.viewDidLoad()
        add("Ana", to: viewModel)
        add("Bruno", to: viewModel)
        let ana = try #require(store.draft.participants.first { $0.name == "Ana" })
        store.draft.participants[2].forbiddenGiverIDs = [ana.id]

        viewModel.viewWillAppear()

        #expect(viewModel.state.participants.last?.restrictedGiverNames == ["Ana"])
    }

    @Test func contactNameIsAddedEvenWhenTooLong() {
        let viewModel = makeViewModel()
        var onPicked: (@MainActor (String?) -> Void)?
        viewModel.onNavigation = { navigation in
            if case .pickContact(let callback) = navigation {
                onPicked = callback
            }
        }
        viewModel.viewDidLoad()

        viewModel.didTapAddFromContacts()
        onPicked?("Maria Aparecida dos Santos Oliveira")

        #expect(viewModel.state.participants.first?.error == .tooLong(limit: FieldLimits.participantName))
    }

    @Test func contactWithoutNameShowsAWarning() {
        let viewModel = makeViewModel()
        var onPicked: (@MainActor (String?) -> Void)?
        viewModel.onNavigation = { navigation in
            if case .pickContact(let callback) = navigation {
                onPicked = callback
            }
        }
        viewModel.viewDidLoad()

        viewModel.didTapAddFromContacts()
        onPicked?(nil)

        #expect(viewModel.state.participants.isEmpty)
        #expect(viewModel.state.footer == .contactWithoutName)
    }

    @Test func limitDisablesAdding() {
        let store = CreateGroupDraftStore()
        let viewModel = makeViewModel(store: store)
        viewModel.viewDidLoad()

        for index in 1..<FieldLimits.maxParticipants {
            add("Pessoa \(index)", to: viewModel)
        }
        add("Mais uma", to: viewModel)

        #expect(store.draft.participants.count == FieldLimits.maxParticipants)
        #expect(viewModel.state.isAddEnabled == false)
        #expect(viewModel.state.footer == .limitReached)
    }
}
