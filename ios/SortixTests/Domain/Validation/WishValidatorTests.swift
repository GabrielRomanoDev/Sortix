import Testing
@testable import Sortix

struct WishValidatorTests {
    @Test func descriptionIsRequiredAndLimited() {
        #expect(WishValidator.validateDescription("") == .empty)
        #expect(WishValidator.validateDescription(String(repeating: "a", count: 100)) == nil)
        #expect(WishValidator.validateDescription(String(repeating: "a", count: 101)) == .tooLong(limit: 100))
    }

    @Test func optionalFieldLimits() {
        #expect(WishValidator.validateSize(String(repeating: "a", count: 21)) == .tooLong(limit: 20))
        #expect(WishValidator.validateColor(String(repeating: "a", count: 31)) == .tooLong(limit: 30))
        #expect(WishValidator.validateNotes(String(repeating: "a", count: 281)) == .tooLong(limit: 280))
        #expect(WishValidator.validateSize("") == nil)
    }

    @Test func linkLimitCountsTheNormalizedLink() {
        let base = "https://loja.com/"
        let exactly2000 = base + String(repeating: "a", count: 2_000 - base.count)

        #expect(WishValidator.validateLink(exactly2000) == nil)
        #expect(WishValidator.validateLink(exactly2000 + "a") == .tooLong(limit: 2_000))
        #expect(WishValidator.validateLink("javascript:alert(1)") == .invalidLink)
        #expect(WishValidator.validateLink("   ") == nil)
    }

    @Test func descriptionOnlyAndAllFieldsAreValid() {
        #expect(WishValidator.isValid(WishDraft(description: "Livro")))
        #expect(WishValidator.isValid(WishDraft(
            description: "Moletom",
            size: "M",
            color: "Cinza",
            notes: "Sem estampa",
            link: "loja.com/moletom"
        )))
    }
}
