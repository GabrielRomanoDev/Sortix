import Foundation

/// Everything coordinators need to build scenes, created once per scene and passed down through
/// initializers. Coordinators hand each ViewModel only the dependencies it uses.
///
/// Services join this type as their stages land (section 6.5 of the specification).
struct AppDependencies {
    let authService: any AuthServiceProtocol
    let drawService: any DrawServiceProtocol
    let crashReporter: any CrashReporterProtocol
    let locale: Locale
}
