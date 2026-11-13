import OSLog

/// App loggers, one per area. Use them instead of `print`.
///
/// Always log dynamic values with `privacy: .private`, and never log tokens, names, suggestions
/// or draw results (BR-55).
enum AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "Sortix"

    static let app = Logger(subsystem: subsystem, category: "app")
    static let navigation = Logger(subsystem: subsystem, category: "navigation")
    static let services = Logger(subsystem: subsystem, category: "services")
    static let draw = Logger(subsystem: subsystem, category: "draw")
}
