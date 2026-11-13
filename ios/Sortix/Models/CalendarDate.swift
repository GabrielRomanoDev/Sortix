import Foundation

/// A date without time, such as the event date (BR-04).
///
/// It is stored as `YYYY-MM-DD` text, so the day never shifts when read in another time zone.
struct CalendarDate: Hashable, Comparable, Sendable {
    let year: Int
    let month: Int
    let day: Int

    init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }

    /// The day `date` falls on in `calendar`.
    init(date: Date, calendar: Calendar) {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        self.init(year: components.year ?? 0, month: components.month ?? 0, day: components.day ?? 0)
    }

    /// Reads `YYYY-MM-DD`. Returns `nil` for any other format.
    init?(isoString: String) {
        let parts = isoString.split(separator: "-")
        guard
            parts.count == 3,
            parts[0].count == 4, parts[1].count == 2, parts[2].count == 2,
            let year = Int(parts[0]), let month = Int(parts[1]), let day = Int(parts[2]),
            (1...12).contains(month), (1...31).contains(day)
        else { return nil }
        self.init(year: year, month: month, day: day)
    }

    /// The `YYYY-MM-DD` text sent to the server.
    var isoString: String {
        String(format: "%04d-%02d-%02d", year, month, day)
    }

    /// Midnight of this day in `calendar`, used to format the date for display.
    func date(in calendar: Calendar) -> Date? {
        calendar.date(from: DateComponents(year: year, month: month, day: day))
    }

    static func < (lhs: CalendarDate, rhs: CalendarDate) -> Bool {
        (lhs.year, lhs.month, lhs.day) < (rhs.year, rhs.month, rhs.day)
    }
}
