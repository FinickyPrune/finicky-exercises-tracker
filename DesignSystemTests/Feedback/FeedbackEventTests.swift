@testable import DesignSystem
import SwiftUI
import Testing

/// The catalog from docs/DESIGN.md → «Отклик».
struct FeedbackEventTests {
    private static let catalog: [FeedbackEvent: [SensoryFeedback]] = [
        .stepCompleted: [.success],
        .factChanged: [.selection],
        .routineCompleted: [.success, .impact(weight: .heavy)],
        .dayPartCompleted: [.success],
        .timerTick: [.impact(weight: .light)],
        .timerFinished: [.impact(weight: .heavy)],
        .undone: [.impact(flexibility: .soft)],
    ]

    /// A new event without a row in the catalog fails here instead of being skipped.
    @Test(arguments: FeedbackEvent.allCases)
    func hapticsMatchTheCatalog(event: FeedbackEvent) throws {
        let expected = try #require(Self.catalog[event])
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

}
