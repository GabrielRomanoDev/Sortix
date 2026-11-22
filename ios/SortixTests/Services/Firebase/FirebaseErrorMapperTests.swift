import Foundation
import Testing
@testable import Sortix

/// Errors are built by hand with the domains and codes Firebase uses, so the tests need no
/// network and no Firebase import.
struct FirebaseErrorMapperTests {
    private enum FirestoreCode {
        static let deadlineExceeded = 4
        static let notFound = 5
        static let permissionDenied = 7
        static let resourceExhausted = 8
        static let unavailable = 14
        static let unauthenticated = 16
    }

    private struct OtherError: Error {}

    private func firestoreError(_ code: Int) -> NSError {
        NSError(domain: "FIRFirestoreErrorDomain", code: code)
    }

    private func authError(_ code: Int) -> NSError {
        NSError(domain: "FIRAuthErrorDomain", code: code)
    }

    @Test(arguments: [FirestoreCode.unavailable, FirestoreCode.deadlineExceeded])
    func connectionProblemsAreNetwork(code: Int) {
        let error = FirebaseErrorMapper.serviceError(from: firestoreError(code), operation: .openLink)

        #expect(error == .network)
    }

    @Test func exhaustedQuotaIsQuotaExceeded() {
        let error = FirebaseErrorMapper.serviceError(
            from: firestoreError(FirestoreCode.resourceExhausted),
            operation: .createGroup
        )

        #expect(error == .quotaExceeded)
    }

    @Test func firestoreUnauthenticatedIsUnauthenticated() {
        let error = FirebaseErrorMapper.serviceError(
            from: firestoreError(FirestoreCode.unauthenticated),
            operation: .observeGroup
        )

        #expect(error == .unauthenticated)
    }

    @Test(arguments: [
        (ServiceOperation.openLink, ServiceError.organizerLinkBlocked),
        (.reveal, .organizerLinkBlocked),
        (.changeWish, .organizerLinkBlocked),
        (.observeGroup, .notOrganizer),
        (.markLinkShared, .notOrganizer),
        (.deleteGroup, .notOrganizer),
        (.createGroup, .unknown),
        (.claimGroup, .unknown)
    ])
    func permissionDeniedDependsOnTheOperation(operation: ServiceOperation, expected: ServiceError) {
        let error = FirebaseErrorMapper.serviceError(
            from: firestoreError(FirestoreCode.permissionDenied),
            operation: operation
        )

        #expect(error == expected)
    }

    @Test(arguments: [
        (ServiceOperation.openLink, ServiceError.linkNotFound),
        (.recoveryPreview, .linkNotFound),
        (.observeGroup, .groupNotFound),
        (.markLinkShared, .groupNotFound),
        (.createGroup, .unknown)
    ])
    func notFoundDependsOnTheOperation(operation: ServiceOperation, expected: ServiceError) {
        let error = FirebaseErrorMapper.serviceError(
            from: firestoreError(FirestoreCode.notFound),
            operation: operation
        )

        #expect(error == expected)
    }

    @Test func authNetworkErrorIsNetwork() {
        let error = FirebaseErrorMapper.serviceError(from: authError(17020), operation: .signIn)

        #expect(error == .network)
    }

    @Test func otherAuthErrorsAreUnauthenticated() {
        let error = FirebaseErrorMapper.serviceError(from: authError(17999), operation: .signIn)

        #expect(error == .unauthenticated)
    }

    @Test func keepsAServiceError() {
        let error = FirebaseErrorMapper.serviceError(from: ServiceError.wishNotFound, operation: .changeWish)

        #expect(error == .wishNotFound)
    }

    @Test func unknownErrorsAreUnknown() {
        #expect(FirebaseErrorMapper.serviceError(from: OtherError(), operation: .reveal) == .unknown)
    }
}
