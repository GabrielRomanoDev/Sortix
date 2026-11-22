import Testing
@testable import Sortix

struct FirestorePathsTests {
    private let groupID = GroupID(rawValue: "g1")
    private let participantID = ParticipantID(rawValue: "p1")
    private let userID = UserID(rawValue: "u1")

    @Test func groupPaths() {
        #expect(FirestorePaths.group(groupID) == "groups/g1")
        #expect(FirestorePaths.participants(of: groupID) == "groups/g1/participants")
        #expect(FirestorePaths.participant(participantID, of: groupID) == "groups/g1/participants/p1")
        #expect(FirestorePaths.wishList(of: participantID, in: groupID) == "groups/g1/wishLists/p1")
    }

    @Test func tokenPaths() {
        let token = AccessToken(rawValue: "abc")

        #expect(FirestorePaths.token(token) == "tokens/abc")
        #expect(FirestorePaths.assignment(token) == "assignments/abc")
        #expect(FirestorePaths.recoveryToken(RecoveryToken(rawValue: "xyz")) == "recoveryTokens/xyz")
    }

    @Test func membershipPaths() {
        #expect(FirestorePaths.memberships(of: userID) == "users/u1/memberships")
        #expect(FirestorePaths.membership(of: userID, in: groupID) == "users/u1/memberships/g1")
    }
}
