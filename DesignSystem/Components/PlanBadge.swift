import SwiftUI

/// A plan or fact: «3 × 15 reps», «3 × 0:30». The amount is large, sets and unit are small.
public struct PlanBadge: View {
    /// What one set consists of.
    public enum Amount: Hashable, Sendable {
        case reps(Int)
        case duration(seconds: Int)
    }

    private let sets: Int
    private let amount: Amount
    private let size: Font.TextStyle

    @Environment(\.locale) private var locale

    /// - Parameter size: text style of the large number; `.title2` for the next exercise, `.title3` otherwise.
    public init(sets: Int, amount: Amount, size: Font.TextStyle = .title3) {
        self.sets = sets
        self.amount = amount
        self.size = size
    }

    public var body: some View {
        let prefix = Text("\(sets) × ").font(.planUnit)
        let value = Text(amount.value).font(.planNumber(size))
        Group {
            if let unit = amount.unit {
                let unit = Text(unit).font(.planUnit)
                Text("\(prefix)\(value) \(unit)")
            } else {
                Text("\(prefix)\(value)")
            }
        }
        .monospacedDigit()
        .accessibilityLabel(Self.spokenLabel(sets: sets, amount: amount, locale: locale))
    }

    /// VoiceOver reads «3 ×» as a formula, so the label spells it out.
    nonisolated static func spokenLabel(sets: Int, amount: Amount, locale: Locale) -> String {
        switch amount {
        case let .reps(count):
            return LocalizedStringResource.planSpokenReps(sets, count).string(in: locale)
        case let .duration(seconds):
            let style = Duration.UnitsFormatStyle(allowedUnits: [.minutes, .seconds], width: .wide).locale(locale)
            let duration = Duration.seconds(max(0, seconds)).formatted(style)
            return LocalizedStringResource.planSpokenDuration(sets, duration).string(in: locale)
        }
    }
}

public extension PlanBadge.Amount {
    /// The large part: «15» or «0:30».
    nonisolated var value: String {
        switch self {
        case let .reps(count):
            "\(count)"
        case let .duration(seconds):
            Duration.seconds(max(0, seconds)).formatted(.time(pattern: .minuteSecond))
        }
    }

    /// The small part after the value: «reps»; durations need none.
    nonisolated var unit: LocalizedStringResource? {
        switch self {
        case .reps: .planRepsUnit
        case .duration: nil
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: Spacing.small) {
        PlanBadge(sets: 3, amount: .reps(15))
        PlanBadge(sets: 3, amount: .duration(seconds: 30))
        PlanBadge(sets: 1, amount: .duration(seconds: 90), size: .title2)
    }
    .foregroundStyle(Palette.textPrimary)
    .padding(Spacing.screenEdge)
    .background(Palette.background)
}

#Preview("Dark, large text") {
    VStack(alignment: .leading, spacing: Spacing.small) {
        PlanBadge(sets: 3, amount: .reps(15))
        PlanBadge(sets: 3, amount: .duration(seconds: 30))
        PlanBadge(sets: 1, amount: .duration(seconds: 90), size: .title2)
    }
    .foregroundStyle(Palette.textPrimary)
    .padding(Spacing.screenEdge)
    .background(Palette.background)
    .dynamicTypeSize(.xxxLarge)
    .preferredColorScheme(.dark)
}
