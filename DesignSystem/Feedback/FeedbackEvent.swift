import SwiftUI

/// Something the user did or finished that the app answers with a haptic and an animation.
/// The catalog is docs/DESIGN.md → «Отклик»; features never call haptics directly.
public nonisolated enum FeedbackEvent: CaseIterable, Hashable, Sendable {
    /// A step marked «по плану».
    case stepCompleted
    /// The fact of a step was edited.
    case factChanged
    /// The last step of a routine is done.
    case routineCompleted
    /// The last routine of a part of the day is done.
    case dayPartCompleted
    /// Each of the last three seconds of a timer.
    case timerTick
    case timerFinished
    /// A completion was taken back.
    case undone

    /// Played together when the event fires; the first is the main one.
    public var haptics: [SensoryFeedback] {
        switch self {
        case .stepCompleted: [.success]
        case .factChanged: [.selection]
        case .routineCompleted: [.success, .impact(weight: .heavy)]
        case .dayPartCompleted: [.success]
        case .timerTick: [.impact(weight: .light)]
        case .timerFinished: [.impact(weight: .heavy)]
        case .undone: [.impact(flexibility: .soft)]
        }
    }

    /// Celebrations get a bouncy spring and are replaced by a plain fade when Reduce Motion is on.
    public var isCelebration: Bool {
        switch self {
        case .routineCompleted, .dayPartCompleted: true
        default: false
        }
    }

    /// The animation for this event. Under Reduce Motion a celebration becomes a short fade — «простое появление».
    public func animation(reduceMotion: Bool) -> Animation {
        if isCelebration {
            return reduceMotion ? .easeInOut(duration: Motion.fadeDuration) : .bouncy
        }
        return .snappy
    }
}

/// Timing shared by the feedback animations.
public nonisolated enum Motion {
    /// The fade that replaces celebrations under Reduce Motion.
    public static let fadeDuration = 0.25
    /// How long the full-screen celebration stays.
    public static let celebrationDuration = 1.5
}

public extension View {
    /// Plays the haptics of `event` each time `trigger` changes.
    ///
    ///     .feedback(.stepCompleted, trigger: completedCount)
    func feedback(_ event: FeedbackEvent, trigger: some Equatable) -> some View {
        sensoryFeedback(trigger: trigger) { _, _ in event.haptics.first }
            .sensoryFeedback(trigger: trigger) { _, _ in event.haptics.dropFirst().first }
    }

    /// Animates changes of `value` the way `event` should look, honoring Reduce Motion.
    func feedbackAnimation(_ event: FeedbackEvent, value: some Equatable) -> some View {
        modifier(FeedbackAnimationModifier(event: event, value: value))
    }
}

private struct FeedbackAnimationModifier<Value: Equatable>: ViewModifier {
    let event: FeedbackEvent
    let value: Value

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content.animation(event.animation(reduceMotion: reduceMotion), value: value)
    }
}
