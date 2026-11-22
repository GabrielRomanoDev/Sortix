/// Every Firestore path the app uses, built in one place (section 13.5). The collections are
/// described in section 11.2.
///
/// Paths contain tokens, so never log them (BR-55).
enum FirestorePaths {
    static let groups = "groups"
    static let tokens = "tokens"
    static let assignments = "assignments"
    static let recoveryTokens = "recoveryTokens"

    static func group(_ groupID: GroupID) -> String {
        "\(groups)/\(groupID.rawValue)"
    }

    static func participants(of groupID: GroupID) -> String {
        "\(group(groupID))/participants"
    }

    static func participant(_ participantID: ParticipantID, of groupID: GroupID) -> String {
        "\(participants(of: groupID))/\(participantID.rawValue)"
    }

    static func wishList(of participantID: ParticipantID, in groupID: GroupID) -> String {
        "\(group(groupID))/wishLists/\(participantID.rawValue)"
    }

    static func token(_ token: AccessToken) -> String {
        "\(tokens)/\(token.rawValue)"
    }

    static func assignment(_ token: AccessToken) -> String {
        "\(assignments)/\(token.rawValue)"
    }

    static func recoveryToken(_ token: RecoveryToken) -> String {
        "\(recoveryTokens)/\(token.rawValue)"
    }

    static func memberships(of userID: UserID) -> String {
        "users/\(userID.rawValue)/memberships"
    }

    static func membership(of userID: UserID, in groupID: GroupID) -> String {
        "\(memberships(of: userID))/\(groupID.rawValue)"
    }
}
