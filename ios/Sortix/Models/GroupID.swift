/// Identifies a group. Created on the device before the draw, so the app can retry `createGroup` safely.
struct GroupID: Hashable, Sendable {
    let rawValue: String
}
