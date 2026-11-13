/// The organizer's secret that moves the group to another device (`/r/<token>`).
///
/// Never log it or show it in error reports (BR-55).
struct RecoveryToken: Hashable, Sendable {
    let rawValue: String
}
