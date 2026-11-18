import Foundation
@testable import Sortix

extension AppDependencies {
    /// Dependencies for coordinator tests, with a fixed locale so formatting is predictable.
    static func mock(
        drawService: any DrawServiceProtocol = MockDrawService(),
        locale: Locale = Locale(identifier: "pt_BR")
    ) -> AppDependencies {
        AppDependencies(drawService: drawService, locale: locale)
    }
}
