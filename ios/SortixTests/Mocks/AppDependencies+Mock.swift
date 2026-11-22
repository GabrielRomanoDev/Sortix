import Foundation
@testable import Sortix

extension AppDependencies {
    /// Dependencies for coordinator tests, with a fixed locale so formatting is predictable.
    @MainActor
    static func mock(
        authService: any AuthServiceProtocol = MockAuthService(),
        drawService: any DrawServiceProtocol = MockDrawService(),
        settingsStore: any LocalSettingsStoreProtocol = MockSettingsStore(),
        crashReporter: any CrashReporterProtocol = MockCrashReporter(),
        locale: Locale = Locale(identifier: "pt_BR")
    ) -> AppDependencies {
        AppDependencies(
            authService: authService,
            drawService: drawService,
            settingsStore: settingsStore,
            crashReporter: crashReporter,
            locale: locale
        )
    }
}
