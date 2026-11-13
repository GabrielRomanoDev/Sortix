import Foundation

/// Reads the JSON vectors in `shared/test-vectors/`, which the TypeScript tests read too.
///
/// The file is located from this source file's path. Simulator tests run on the Mac, so the
/// repository is readable without copying the vectors into the test bundle.
enum TestVectors {
    struct Normalization: Decodable {
        struct Case: Decodable, Sendable {
            let input: String
            let expected: String
        }

        struct CountCase: Decodable, Sendable {
            let input: String
            let expected: Int
        }

        let normalization: [Case]
        let graphemeCount: [CountCase]
    }

    static func normalization() throws -> Normalization {
        try load("normalization.json")
    }

    private static func load<Vectors: Decodable>(_ fileName: String) throws -> Vectors {
        let repositoryRoot = URL(filePath: #filePath)
            .deletingLastPathComponent() // Support
            .deletingLastPathComponent() // SortixTests
            .deletingLastPathComponent() // ios
            .deletingLastPathComponent()
        let fileURL = repositoryRoot.appending(path: "shared/test-vectors/\(fileName)")
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode(Vectors.self, from: data)
    }
}
