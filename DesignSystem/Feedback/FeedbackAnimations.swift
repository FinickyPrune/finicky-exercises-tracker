import SwiftUI

/// A checkmark that draws itself when `isOn` turns true and erases when it turns false
/// («шаг выполнен» and «отмена выполнения»). Under Reduce Motion it fades instead.
public struct AnimatedCheckmark: View {
    private let isOn: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ScaledMetric(relativeTo: .body) private var lineWidth = 3.0

    public init(isOn: Bool) {
        self.isOn = isOn
    }

    public var body: some View {
        CheckmarkShape()
            .trim(from: 0, to: reduceMotion || isOn ? 1 : 0)
            .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
            .opacity(isOn ? 1 : 0)
            .animation(.snappy, value: isOn)
            .accessibilityHidden(true)
    }
}

private nonisolated struct CheckmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + rect.width * 0.2, y: rect.midY + rect.height * 0.02))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.42, y: rect.maxY - rect.height * 0.25))
        path.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.18, y: rect.minY + rect.height * 0.27))
        return path
    }
}

public extension View {
    /// A short white flash over the view each time `trigger` changes: «рутина завершена».
    /// The flash is a rectangle: clip the view afterwards (`.clipShape(.card)`) to keep rounded corners.
    /// Skipped under Reduce Motion.
    func completionFlash(trigger: some Equatable & Sendable) -> some View {
        modifier(CompletionFlash(trigger: trigger))
    }

    /// A quick swell each time `trigger` changes: the timer ring in its last seconds.
    /// Skipped under Reduce Motion.
    func pulse(trigger: some Equatable & Sendable) -> some View {
        modifier(Pulse(trigger: trigger))
    }
}

/// White in every appearance: `onAccent` turns dark under Increase Contrast in dark mode.
private let flashColor = ColorToken("flash", light: 0xFFFFFF, dark: 0xFFFFFF)

// The effects keep one view structure and only zero out the motion under Reduce Motion,
// so toggling the setting does not reset the state of the content they wrap.

private struct CompletionFlash<Trigger: Equatable & Sendable>: ViewModifier {
    let trigger: Trigger

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        let reduceMotion = reduceMotion
        return content.overlay {
            Rectangle()
                .fill(flashColor)
                .keyframeAnimator(initialValue: 0.0, trigger: trigger) { view, opacity in
                    view.opacity(reduceMotion ? 0 : opacity)
                } keyframes: { _ in
                    LinearKeyframe(0.45, duration: 0.08)
                    LinearKeyframe(0, duration: 0.35)
                }
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
    }
}

private struct Pulse<Trigger: Equatable & Sendable>: ViewModifier {
    let trigger: Trigger

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        let reduceMotion = reduceMotion
        return content.keyframeAnimator(initialValue: 1.0, trigger: trigger) { view, scale in
            view.scaleEffect(reduceMotion ? 1 : scale)
        } keyframes: { _ in
            SpringKeyframe(1.08, duration: 0.15)
            SpringKeyframe(1, duration: 0.3)
        }
    }
}

/// Full-screen celebration when a part of the day is done: a burst of accent dots and a large checkmark.
/// Hides itself after `Motion.celebrationDuration` and announces itself to VoiceOver.
/// Under Reduce Motion only the checkmark fades in and out.
///
/// Setting `isPresented` to true again while it is shown does not restart it.
///
///     .overlay { CelebrationOverlay(isPresented: $celebrating) }
public struct CelebrationOverlay: View {
    @Binding private var isPresented: Bool

    public init(isPresented: Binding<Bool>) {
        _isPresented = isPresented
    }

    public var body: some View {
        ZStack {
            if isPresented {
                // A new content view on every presentation, so its animation starts from zero each time.
                CelebrationContent()
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(false)
        .task(id: isPresented) {
            guard isPresented else { return }
            AccessibilityNotification.Announcement("Часть дня выполнена").post()
            do {
                try await Task.sleep(for: .seconds(Motion.celebrationDuration))
            } catch {
                return // Cancelled: a newer presentation or the view going away owns `isPresented` now.
            }
            withAnimation(.easeOut(duration: Motion.fadeDuration)) { isPresented = false }
        }
    }
}

private struct CelebrationContent: View {
    @State private var progress = 0.0

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ScaledMetric(relativeTo: .largeTitle) private var badgeSize = 96.0

    private static let dotCount = 14

    var body: some View {
        ZStack {
            if !reduceMotion {
                ForEach(0 ..< Self.dotCount, id: \.self) { index in
                    Circle()
                        .fill(index.isMultiple(of: 2) ? Palette.accent : RoutineTint.amber.token)
                        .frame(width: Spacing.small, height: Spacing.small)
                        .offset(x: badgeSize * 1.6 * progress)
                        .rotationEffect(.degrees(Double(index) / Double(Self.dotCount) * 360))
                        .opacity(1 - progress * 0.6)
                }
            }
            Image(systemName: "checkmark")
                .font(.system(size: badgeSize * 0.45, weight: .bold))
                .foregroundStyle(Palette.onAccent)
                .frame(width: badgeSize, height: badgeSize)
                .background(Palette.accent, in: .circle)
                .scaleEffect(reduceMotion ? 1 : 0.4 + 0.6 * progress)
        }
        .accessibilityHidden(true)
        .onAppear {
            withAnimation(FeedbackEvent.dayPartCompleted.animation(reduceMotion: reduceMotion)) { progress = 1 }
        }
    }
}

#Preview("Галочка") {
    @Previewable @State var isOn = false
    VStack(spacing: Spacing.large) {
        AnimatedCheckmark(isOn: isOn)
            .foregroundStyle(Palette.accent)
            .frame(width: Size.button, height: Size.button)
        CapsuleButton(isOn ? "Отменить" : "По плану") { isOn.toggle() }
    }
    .padding(Spacing.screenEdge)
    .background(Palette.background)
}

#Preview("Праздник") {
    @Previewable @State var celebrating = false
    CapsuleButton("Завершить утро") { celebrating = true }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Palette.background)
        .overlay { CelebrationOverlay(isPresented: $celebrating) }
}

#Preview("Тёмная") {
    @Previewable @State var flashes = 0
    RoutineCard("Зарядка", status: "6 из 6", symbol: "figure.cooldown", tint: Palette.accent, state: .current)
        .completionFlash(trigger: flashes)
        .clipShape(.card)
        .onTapGesture { flashes += 1 }
        .padding(Spacing.screenEdge)
        .background(Palette.background)
        .preferredColorScheme(.dark)
}
