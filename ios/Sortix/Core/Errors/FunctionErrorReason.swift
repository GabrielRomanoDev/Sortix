/// Reason codes the Cloud Functions send in `details.reason` (section 13.2 of the specification).
///
/// The raw values must stay identical to the server's. The server never sends user-facing text,
/// only these codes; the app turns them into messages with `ErrorMessageMapper`.
enum FunctionErrorReason: String, Equatable, Sendable {
    case invalidRequest = "INVALID_REQUEST"
    case invalidToken = "INVALID_TOKEN"
    case linkNotFound = "LINK_NOT_FOUND"
    case invalidGroupName = "INVALID_GROUP_NAME"
    case invalidRules = "INVALID_RULES"
    case invalidParticipants = "INVALID_PARTICIPANTS"
    case invalidParticipantName = "INVALID_PARTICIPANT_NAME"
    case duplicatedParticipantName = "DUPLICATED_PARTICIPANT_NAME"
    case invalidRestriction = "INVALID_RESTRICTION"
    case invalidAssignment = "INVALID_ASSIGNMENT"
    case groupIDConflict = "GROUP_ID_CONFLICT"
    case notOrganizer = "NOT_ORGANIZER"
    case groupNotFound = "GROUP_NOT_FOUND"
    case invalidWish = "INVALID_WISH"
    case wishLimitReached = "WISH_LIMIT_REACHED"
    case wishNotFound = "WISH_NOT_FOUND"
}
