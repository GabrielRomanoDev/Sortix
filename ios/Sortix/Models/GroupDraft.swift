/// A group being created. It lives only in memory until the draw (BR-06).
struct GroupDraft: Equatable, Sendable {
    var name: String = ""
    var rules = GroupRules()
    /// The organizer is always the first participant (BR-11).
    var participants: [ParticipantDraft] = []
}
