@testable import ExercisesTracker
import Foundation
import Testing

struct DayKeyTests {
    private func calendar(_ zone: String) throws -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try #require(TimeZone(identifier: zone))
        return calendar
    }

    private func date(_ calendar: Calendar, _ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int = 0,
                      _ second: Int = 0) throws -> Date {
        try #require(calendar.date(from: DateComponents(
            year: year, month: month, day: day, hour: hour, minute: minute, second: second
        )))
    }

    @Test func isYearMonthDay() throws {
        let belgrade = try calendar("Europe/Belgrade")
        #expect(try DayKey.of(date(belgrade, 2026, 10, 2, 7), in: belgrade) == 20_261_002)
    }

    @Test func changesExactlyAtMidnight() throws {
        let belgrade = try calendar("Europe/Belgrade")
        #expect(try DayKey.of(date(belgrade, 2026, 10, 2, 23, 59, 59), in: belgrade) == 20_261_002)
        #expect(try DayKey.of(date(belgrade, 2026, 10, 3, 0), in: belgrade) == 20_261_003)
    }

    @Test func rollsOverMonthAndYear() throws {
        let belgrade = try calendar("Europe/Belgrade")
        #expect(try DayKey.of(date(belgrade, 2026, 12, 31, 23, 30), in: belgrade) == 20_261_231)
        #expect(try DayKey.of(date(belgrade, 2027, 1, 1, 0, 30), in: belgrade) == 20_270_101)
    }

    /// The same instant is a different day in another time zone; the key follows the calendar it was made in.
    @Test func dependsOnTimeZoneOfTheCalendar() throws {
        let belgrade = try calendar("Europe/Belgrade")
        let tokyo = try calendar("Asia/Tokyo")
        let lateEvening = try date(belgrade, 2026, 10, 2, 22) // 05:00 on Oct 3 in Tokyo
        #expect(DayKey.of(lateEvening, in: belgrade) == 20_261_002)
        #expect(DayKey.of(lateEvening, in: tokyo) == 20_261_003)
    }

    /// A day with a daylight-saving switch is still one day.
    @Test func daylightSavingDayIsOneDay() throws {
        let belgrade = try calendar("Europe/Belgrade")
        // 2026-03-29: clocks jump from 02:00 to 03:00.
        #expect(try DayKey.of(date(belgrade, 2026, 3, 29, 1, 30), in: belgrade) == 20_260_329)
        #expect(try DayKey.of(date(belgrade, 2026, 3, 29, 23, 30), in: belgrade) == 20_260_329)
    }

    /// In autumn 02:30 happens twice; both are the same day.
    @Test func fallBackDayIsOneDay() throws {
        let belgrade = try calendar("Europe/Belgrade")
        // 2026-10-25: clocks go back from 03:00 to 02:00. 00:30 UTC and 01:30 UTC are both 02:30 local.
        let first = Date(timeIntervalSince1970: 1_792_888_200) // 2026-10-25 00:30 UTC
        let second = first.addingTimeInterval(3600)
        #expect(DayKey.of(first, in: belgrade) == 20_261_025)
        #expect(DayKey.of(second, in: belgrade) == 20_261_025)
    }

    /// A user with the Buddhist calendar still gets Gregorian keys (2026, not 2569).
    @Test(arguments: [Calendar.Identifier.buddhist, .japanese, .islamicUmmAlQura])
    func isGregorianWhateverTheUserCalendar(identifier: Calendar.Identifier) throws {
        let belgrade = try calendar("Europe/Belgrade")
        var other = Calendar(identifier: identifier)
        other.timeZone = belgrade.timeZone
        #expect(try DayKey.of(date(belgrade, 2026, 10, 2, 7), in: other) == 20_261_002)
    }

    @Test func componentsRoundTrip() throws {
        let belgrade = try calendar("Europe/Belgrade")
        let parts = DayKey.components(of: 20_261_002)
        #expect(parts.year == 2026 && parts.month == 10 && parts.day == 2)
        let day = try #require(belgrade.date(from: parts))
        #expect(DayKey.of(day, in: belgrade) == 20_261_002)
    }
}
