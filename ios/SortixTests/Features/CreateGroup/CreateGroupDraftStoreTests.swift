import Testing
@testable import Sortix

@MainActor
struct CreateGroupDraftStoreTests {
    @Test func emptyOrBlankDraftHasNoData() {
        let store = CreateGroupDraftStore()
        #expect(store.hasData == false)

        store.draft.name = "   "
        store.draft.rules.location = ""
        #expect(store.hasData == false)
    }

    @Test func anyFilledFieldCountsAsData() {
        let store = CreateGroupDraftStore()
        store.draft.rules.maxGiftValue = Money(amountMinor: 5_000, currencyCode: "BRL")

        #expect(store.hasData)
    }
}
