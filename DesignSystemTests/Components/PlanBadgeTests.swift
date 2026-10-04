@testable import DesignSystem
import Testing

struct PlanBadgeTests {
    @Test func repsShowCountAndUnit() {
        let amount = PlanBadge.Amount.reps(15)
        #expect(amount.value == "15")
        #expect(amount.unit == " повт")
    }

    @Test(arguments: [(30, "0:30"), (90, "1:30"), (5, "0:05"), (600, "10:00")])
    func durationIsMinutesAndPaddedSeconds(seconds: Int, expected: String) {
        let amount = PlanBadge.Amount.duration(seconds: seconds)
        #expect(amount.value == expected)
        #expect(amount.unit.isEmpty)
    }

    @Test func spokenLabelSpellsOutReps() {
        #expect(PlanBadge.spokenLabel(sets: 3, amount: .reps(15)) == "Подходов: 3, повторений: 15")
    }

    @Test(arguments: [
        (30, "Подходов: 3, по 30 секунд"),
        (90, "Подходов: 3, по 1 минута 30 секунд"),
    ])
    func spokenLabelSpellsOutDuration(seconds: Int, expected: String) {
        #expect(PlanBadge.spokenLabel(sets: 3, amount: .duration(seconds: seconds)) == expected)
    }

    @Test func negativeDurationShowsZero() {
        #expect(PlanBadge.Amount.duration(seconds: -5).value == "0:00")
    }
}
