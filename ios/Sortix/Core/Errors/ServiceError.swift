/// Errors services report to ViewModels. Firebase errors are converted into these cases, so no
/// layer above the services needs to know Firebase.
enum ServiceError: Error, Equatable, Sendable {
    case network
    case unauthenticated
    case linkNotFound
    case permissionDenied
    /// A Cloud Function refused the request. `field` names the invalid field when the server says.
    case rejected(FunctionErrorReason, field: String?)
    case unknown

    /// Keeps a `ServiceError` as it is and treats any other error as `.unknown`.
    init(_ error: any Error) {
        if let serviceError = error as? ServiceError {
            self = serviceError
        } else {
            self = .unknown
        }
    }
}
