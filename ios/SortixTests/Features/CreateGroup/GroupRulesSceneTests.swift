import Foundation
import Testing
@testable import Sortix
import UIKit

@MainActor
struct GroupRulesSceneTests {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/Sao_Paulo") ?? .gmt
        return calendar
    }()

    /// 10 Nov 2026, 15:00 in São Paulo.
    private var now: Date {
        calendar.date(from: DateComponents(year: 2026, month: 11, day: 10, hour: 15)) ?? .now
    }

    private func makeViewModel(store: CreateGroupDraftStore = CreateGroupDraftStore()) -> GroupRulesViewModel {
        GroupRulesViewModel(draftStore: store, calendar: calendar, locale: Locale(identifier: "pt_BR"), now: now)
    }

    @Test func sceneIsReleased() {
        expectDeallocation {
            let viewModel = makeViewModel()
            let viewController = GroupRulesViewController(viewModel: viewModel)
            viewController.loadViewIfNeeded()
            return [viewController, viewModel]
        }
    }

    @Test func nextStartsDisabledWithoutShowingAnError() {
        let viewModel = makeViewModel()

        viewModel.viewDidLoad()

        #expect(viewModel.state.isNextEnabled == false)
        #expect(viewModel.state.nameError == nil)
    }

    @Test func validNameEnablesNextAndIsSaved() {
        let store = CreateGroupDraftStore()
        let viewModel = makeViewModel(store: store)
        viewModel.viewDidLoad()

        viewModel.didChangeName("Família 2026")

        #expect(viewModel.state.isNextEnabled)
        #expect(store.draft.name == "Família 2026")
    }

    @Test func clearingTheNameShowsTheError() {
        let viewModel = makeViewModel()
        viewModel.viewDidLoad()

        viewModel.didChangeName("A")
        viewModel.didChangeName("  ")

        #expect(viewModel.state.nameError == .empty)
        #expect(viewModel.state.isNextEnabled == false)
    }

    @Test func tooLongNameIsRejected() {
        let viewModel = makeViewModel()
        viewModel.viewDidLoad()

        viewModel.didChangeName(String(repeating: "a", count: FieldLimits.groupName + 1))

        #expect(viewModel.state.nameError == .tooLong(limit: FieldLimits.groupName))
    }

    @Test func maxGiftValueAboveTheLimitBlocksNext() {
        let viewModel = makeViewModel()
        viewModel.viewDidLoad()
        viewModel.didChangeName("Família")

        viewModel.didChangeMaxGiftValue(FieldLimits.maxGiftValueMinor + 1)

        #expect(viewModel.state.maxGiftValueError == .outOfRange)
        #expect(viewModel.state.isNextEnabled == false)
    }

    @Test func clearingTheMaxGiftValueRemovesIt() {
        let store = CreateGroupDraftStore()
        let viewModel = makeViewModel(store: store)
        viewModel.viewDidLoad()

        viewModel.didChangeMaxGiftValue(5_000)
        viewModel.didChangeMaxGiftValue(nil)

        #expect(store.draft.rules.maxGiftValue == nil)
        #expect(viewModel.state.maxGiftValueError == nil)
    }

    @Test func eventDateToggleStartsOnTodayAndClearsWhenOff() {
        let store = CreateGroupDraftStore()
        let viewModel = makeViewModel(store: store)
        viewModel.viewDidLoad()

        viewModel.didToggleEventDate(true)
        #expect(store.draft.rules.eventDate == CalendarDate(year: 2026, month: 11, day: 10))
        #expect(viewModel.state.eventDate != nil)

        viewModel.didToggleEventDate(false)
        #expect(store.draft.rules.eventDate == nil)
        #expect(viewModel.state.eventDate == nil)
    }

    @Test func pastEventDateIsRejected() throws {
        let viewModel = makeViewModel()
        viewModel.viewDidLoad()
        let yesterday = try #require(calendar.date(from: DateComponents(year: 2026, month: 11, day: 9, hour: 12)))

        viewModel.didChangeEventDate(yesterday)

        #expect(viewModel.state.eventDateError == .dateInPast)
    }

    @Test func returningToTheStepShowsTheSavedDraft() {
        let store = CreateGroupDraftStore()
        store.draft.name = "Amigos"
        store.draft.rules.location = "Casa da vó"
        let viewModel = makeViewModel(store: store)

        viewModel.viewDidLoad()

        #expect(viewModel.state.name == "Amigos")
        #expect(viewModel.state.location == "Casa da vó")
        #expect(viewModel.state.isNextEnabled)
    }

    @Test func nextIsIgnoredWhileTheFormIsInvalid() {
        let viewModel = makeViewModel()
        var events: [GroupRulesViewModel.Navigation] = []
        viewModel.onNavigation = { events.append($0) }
        viewModel.viewDidLoad()

        viewModel.didTapNext()
        viewModel.didChangeName("Família")
        viewModel.didTapNext()
        viewModel.didTapCancel()

        #expect(events == [.next, .cancel])
    }
}
