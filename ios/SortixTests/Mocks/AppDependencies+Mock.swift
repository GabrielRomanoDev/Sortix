import Foundation
@testable import Sortix

extension AppDependencies {
    /// Dependencies for coordinator tests, with a fixed locale so formatting is predictable.
    static func mock(locale: Locale = Locale(identifier: "pt_BR")) -> AppDependencies {
        AppDependencies(locale: locale)
    }
}
