@testable import ExercisesTracker
import Foundation
import Testing

struct WeekdaysTests {
    @Test func rawValuesStartAtMonday() {
        #expect(Weekdays.monday.rawValue == 1)
        #expect(Weekdays.sunday.rawValue == 1 << 6)
        #expect(Weekdays.everyDay.rawValue == 0b1111111)
    }

    @Test func groupsCoverTheWeek() {
        #expect(Weekdays.workdays.union(.weekend) == .everyDay)
        #expect(Weekdays.workdays.isDisjoint(with: .weekend))
        #expect(Weekdays.ordered.count == 7)
    }

    /// `Calendar`: 1 = Sunday … 7 = Saturday.
    @Test(arguments: zip(
        1 ... 7,
        [Weekdays.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
    ))
    func mapsCalendarWeekday(calendarWeekday: Int, expected: Weekdays) {
        #expect(Weekdays(calendarWeekday: calendarWeekday) == expected)
    }

    @Test(arguments: [0, 8, -1])
    func outOfRangeCalendarWeekdayIsEmpty(value: Int) {
        #expect(Weekdays(calendarWeekday: value).isEmpty)
    }

    @Test func routineIgnoresStrayBits() {
        let routine = Routine(name: "Зарядка", symbol: "figure.cooldown", colorName: "orange", sortIndex: 0)
        routine.weekdaysRaw = 0xFF
        #expect(routine.weekdays == .everyDay)
    }

    @Test func dateInGregorianCalendar() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try #require(TimeZone(identifier: "Europe/Belgrade"))
        // 2026-10-03 is a Saturday.
        let date = try #require(calendar.date(from: DateComponents(year: 2026, month: 10, day: 3, hour: 7)))
        #expect(Weekdays(date: date, calendar: calendar) == .saturday)
    }

    @Test func codableRoundTrip() throws {
        let days: Weekdays = [.monday, .wednesday, .friday]
        let data = try JSONEncoder().encode(days)
        #expect(try JSONDecoder().decode(Weekdays.self, from: data) == days)
    }
}
