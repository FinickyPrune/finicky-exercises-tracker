@testable import DesignSystem
import Foundation
import Testing

struct PlanBadgeTests {
    private nonisolated static let english = Locale(identifier: "en")
    private nonisolated static let russian = Locale(identifier: "ru")

    @Test func repsShowCountAndUnit() throws {
        let amount = PlanBadge.Amount.reps(15)
        #expect(amount.value == "15")
        let unit = try #require(amount.unit)
        #expect(unit.string(in: Self.english) == "reps")
        #expect(unit.string(in: Self.russian) == "повт")
    }

    @Test(arguments: [(30, "0:30"), (90, "1:30"), (5, "0:05"), (600, "10:00")])
    func durationIsMinutesAndPaddedSeconds(seconds: Int, expected: String) {
        let amount = PlanBadge.Amount.duration(seconds: seconds)
        #expect(amount.value == expected)
        #expect(amount.unit == nil)
    }

    @Test(arguments: [
        (english, "Sets: 3, reps: 15"),
        (russian, "Подходов: 3, повторений: 15"),
    ])
    func spokenLabelSpellsOutReps(locale: Locale, expected: String) {
        #expect(PlanBadge.spokenLabel(sets: 3, amount: .reps(15), locale: locale) == expected)
    }

    @Test(arguments: [
        (english, 30, "Sets: 3, 30 seconds each"),
        (english, 90, "Sets: 3, 1 minute, 30 seconds each"),
        (russian, 30, "Подходов: 3, по 30 секунд"),
        (russian, 90, "Подходов: 3, по 1 минута 30 секунд"),
    ])
    func spokenLabelSpellsOutDuration(locale: Locale, seconds: Int, expected: String) {
        #expect(PlanBadge.spokenLabel(sets: 3, amount: .duration(seconds: seconds), locale: locale) == expected)
    }

    @Test func negativeDurationShowsZero() {
        #expect(PlanBadge.Amount.duration(seconds: -5).value == "0:00")
    }
}
