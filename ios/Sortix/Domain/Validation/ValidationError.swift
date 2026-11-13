/// Why a field or a draft is invalid. ViewControllers turn it into text; tests check the case.
enum ValidationError: Error, Equatable, Sendable {
    case empty
    case tooLong(limit: Int)
    case duplicated
    case outOfRange
    case dateInPast
    case invalidLink
    /// The organizer is missing from the participants or appears more than once (BR-11).
    case invalidOrganizer
    /// A restriction mentions a participant that does not exist or the participant themselves.
    case invalidRestriction
}
