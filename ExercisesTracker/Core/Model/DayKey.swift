import Foundation

/// A day as Gregorian `yyyyMMdd` in the user's time zone: 20261002.
///
/// History and streaks use it instead of `Date`, so a day stays the same day after a time zone change
/// or a daylight-saving switch: it is computed once, when something is recorded, and stored as a number.
nonisolated enum DayKey {
    /// The day `date` falls on in the time zone of `calendar`. The year, month and day are always Gregorian,
    /// whatever calendar the user has chosen (Buddhist, Japanese…), so stored keys do not jump when it changes.
    static func of(_ date: Date, in calendar: Calendar) -> Int {
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = calendar.timeZone
        let parts = gregorian.dateComponents([.year, .month, .day], from: date)
        guard let year = parts.year, let month = parts.month, let day = parts.day else {
            preconditionFailure("A Gregorian calendar always has year, month and day")
        }
        return year * 10000 + month * 100 + day
    }

    /// Gregorian year, month and day of a key; turn them into a date with a Gregorian calendar.
    static func components(of key: Int) -> DateComponents {
        DateComponents(year: key / 10000, month: key / 100 % 100, day: key % 100)
    }
}
