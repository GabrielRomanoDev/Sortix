/// The data operations of section 13.3, plus sign-in.
///
/// `FirebaseErrorMapper` uses it to tell what a `permission-denied` means, and the raw value is
/// the operation name sent as Crashlytics context.
enum ServiceOperation: String, Sendable {
    case signIn
    case createGroup
    case openLink
    case reveal
    case loadWishes
    case changeWish
    case markLinkShared
    case observeGroup
    case deleteGroup
    case recoveryPreview
    case claimGroup
}
