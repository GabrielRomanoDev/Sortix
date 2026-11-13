/// The fields of a gift suggestion being added or edited (BR-38). Optional fields are empty
/// strings while not filled in.
struct WishDraft: Equatable, Sendable {
    var description: String = ""
    var size: String = ""
    var color: String = ""
    var notes: String = ""
    var link: String = ""
}
