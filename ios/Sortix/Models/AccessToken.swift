/// A participant's secret, the last part of their personal link (`/g/<token>`).
///
/// Never log it, show it in error reports or store it outside the membership (BR-55).
struct AccessToken: Hashable, Sendable {
    let rawValue: String
}
