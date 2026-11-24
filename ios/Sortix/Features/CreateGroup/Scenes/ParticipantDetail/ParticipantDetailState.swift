/// Everything the participant detail screen shows.
struct ParticipantDetailState: Equatable {
    var name = ""
    var isOrganizer = false
    /// Hidden while the name is empty: "OK" is disabled, which is enough of a hint.
    var nameError: ValidationError?
    var options: [RestrictionOption] = []
    var isDoneEnabled = false
}
