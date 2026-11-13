import Foundation
import Testing
@testable import Sortix

struct CalendarDateTests {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/Sao_Paulo") ?? .gmt
        return calendar
    }

    @Test func isoStringRoundTrip() {
        let date = CalendarDate(year: 2026, month: 12, day: 5)

        #expect(date.isoString == "2026-12-05")
        #expect(CalendarDate(isoString: "2026-12-05") == date)
    }

    @Test(arguments: ["", "2026-12", "2026/12/05", "26-12-05", "2026-13-01", "2026-12-32", "abcd-ef-gh"])
    func invalidIsoStringIsRejected(text: String) {
        #expect(CalendarDate(isoString: text) == nil)
    }

    @Test func readsTheDayInTheGivenCalendar() throws {
        // 23:30 in São Paulo on Dec 24 is already Dec 25 in UTC.
        let components = DateComponents(year: 2026, month: 12, day: 24, hour: 23, minute: 30)
        let instant = try #require(calendar.date(from: components))

        #expect(CalendarDate(date: instant, calendar: calendar) == CalendarDate(year: 2026, month: 12, day: 24))
    }

    @Test func comparesByDay() {
        let christmasEve = CalendarDate(year: 2026, month: 12, day: 24)
        let christmas = CalendarDate(year: 2026, month: 12, day: 25)
        let newYear = CalendarDate(year: 2027, month: 1, day: 1)

        #expect(christmasEve < christmas)
        #expect(christmas < newYear)
    }
}
