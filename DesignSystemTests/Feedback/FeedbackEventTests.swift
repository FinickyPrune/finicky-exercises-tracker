@testable import DesignSystem
import SwiftUI
import Testing

/// The catalog from docs/DESIGN.md → «Отклик».
struct FeedbackEventTests {
    @Test(arguments: zip(FeedbackEvent.allCases, [
        [SensoryFeedback.success],
        [.selection],
        [.success, .impact(weight: .heavy)],
        [.success],
        [.impact(weight: .light)],
        [.impact(weight: .heavy)],
        [.impact(flexibility: .soft)],
    ]))
    func hapticsMatchTheCatalog(event: FeedbackEvent, expected: [SensoryFeedback]) {
        #expect(event.haptics == expected)
    }

    @Test func onlyCompletionsOfRoutinesAndDayPartsAreCelebrations() {
        let celebrations = FeedbackEvent.allCases.filter(\.isCelebration)
        #expect(celebrations == [.routineCompleted, .dayPartCompleted])
    }

    @Test func celebrationsBounceAndFadeUnderReduceMotion() {
        #expect(FeedbackEvent.dayPartCompleted.animation(reduceMotion: false) == .bouncy)
        let fade = Animation.easeInOut(duration: Motion.fadeDuration)
        #expect(FeedbackEvent.dayPartCompleted.animation(reduceMotion: true) == fade)
    }

    @Test(arguments: FeedbackEvent.allCases.filter { !$0.isCelebration })
    func interactionsStaySnappy(event: FeedbackEvent) {
        #expect(event.animation(reduceMotion: false) == .snappy)
        #expect(event.animation(reduceMotion: true) == .snappy)
    }

    @Test func celebrationFitsTheBudget() {
        #expect(Motion.celebrationDuration <= 1.5)
    }
}
