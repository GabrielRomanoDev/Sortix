import Foundation

extension AppDependencies {
    /// The production dependencies. The only place allowed to create concrete services and, once
    /// Firebase is added, to obtain its instances.
    static func live() -> AppDependencies {
        AppDependencies(locale: .autoupdatingCurrent)
    }
}
