/// The optional rules of a group (BR-02).
struct GroupRules: Equatable, Sendable {
    var maxGiftValue: Money?
    var eventDate: CalendarDate?
    var location: String?
    var notes: String?
}
