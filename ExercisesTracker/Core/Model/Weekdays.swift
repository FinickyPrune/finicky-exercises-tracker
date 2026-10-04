import Foundation

/// Days of the week a routine is scheduled on. Stored in `Routine.weekdaysRaw`: Monday is `1 << 0`, Sunday `1 << 6`.
nonisolated struct Weekdays: OptionSet, Codable, Hashable, Sendable {
    let rawValue: Int

    static let monday = Weekdays(rawValue: 1 << 0)
    static let tuesday = Weekdays(rawValue: 1 << 1)
    static let wednesday = Weekdays(rawValue: 1 << 2)
    static let thursday = Weekdays(rawValue: 1 << 3)
    static let friday = Weekdays(rawValue: 1 << 4)
    static let saturday = Weekdays(rawValue: 1 << 5)
    static let sunday = Weekdays(rawValue: 1 << 6)

    static let workdays: Weekdays = [.monday, .tuesday, .wednesday, .thursday, .friday]
    static let weekend: Weekdays = [.saturday, .sunday]
    static let everyDay: Weekdays = [.workdays, .weekend]

    /// Monday first, the way the week is shown in the app.
    static let ordered: [Weekdays] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]

    init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// The single day for `Calendar.component(.weekday, from:)`, where 1 is Sunday and 7 is Saturday.
    init(calendarWeekday: Int) {
        // Calendar: 1 = Sun, 2 = Mon … 7 = Sat. Ours: bit 0 = Mon … bit 6 = Sun.
        let index = (calendarWeekday + 5) % 7
        self.init(rawValue: 1 << index)
    }

    /// The day of the week `date` falls on in `calendar`.
    init(date: Date, calendar: Calendar) {
        self.init(calendarWeekday: calendar.component(.weekday, from: date))
    }
}
