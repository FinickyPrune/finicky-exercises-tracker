import Foundation

/// A day as `yyyyMMdd` in the user's calendar: 20261002.
///
/// History and streaks use it instead of `Date`, so a day stays the same day after a time zone change
/// or a daylight-saving switch: it is computed once, when something is recorded, and stored as a number.
nonisolated enum DayKey {
    /// The day `date` falls on in `calendar` (and its time zone).
    static func of(_ date: Date, in calendar: Calendar) -> Int {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        return (parts.year ?? 0) * 10000 + (parts.month ?? 0) * 100 + (parts.day ?? 0)
    }

    /// Year, month and day of a key, for turning it back into a date in some calendar.
    static func components(of key: Int) -> DateComponents {
        DateComponents(year: key / 10000, month: key / 100 % 100, day: key % 100)
    }
}
