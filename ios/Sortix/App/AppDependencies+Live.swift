import FirebaseAuth
import FirebaseCrashlytics
import Foundation

extension AppDependencies {
    /// The production dependencies. The only place allowed to create concrete services and to
    /// obtain Firebase instances, which reach the services through their initializers.
    static func live() -> AppDependencies {
        AppDependencies(
            authService: FirebaseAuthService(auth: Auth.auth()),
            drawService: DrawService(engine: DrawEngine()),
            crashReporter: CrashlyticsReporter(crashlytics: Crashlytics.crashlytics()),
            locale: .autoupdatingCurrent
        )
    }
}
