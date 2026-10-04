import SwiftUI

/// A plan or fact: «3 × 15 повт», «3 × 0:30». The amount is large, sets and unit are small.
public struct PlanBadge: View {
    /// What one set consists of.
    public enum Amount: Hashable, Sendable {
        case reps(Int)
        case duration(seconds: Int)
    }

    private let sets: Int
    private let amount: Amount
    private let size: Font.TextStyle

    /// - Parameter size: text style of the large number; `.title2` for the next exercise, `.title3` otherwise.
    public init(sets: Int, amount: Amount, size: Font.TextStyle = .title3) {
        self.sets = sets
        self.amount = amount
        self.size = size
    }

    public var body: some View {
        let prefix = Text("\(sets) × ").font(.planUnit)
        let value = Text(amount.value).font(.planNumber(size))
        let unit = Text(amount.unit).font(.planUnit)
        Text("\(prefix)\(value)\(unit)")
            .monospacedDigit()
            .accessibilityLabel(Self.spokenLabel(sets: sets, amount: amount))
    }

    /// VoiceOver reads «3 ×» as a formula, so the label spells it out.
    /// The app is Russian-only, so the duration is formatted in Russian too, whatever the device language.
    nonisolated static func spokenLabel(sets: Int, amount: Amount) -> String {
        switch amount {
        case let .reps(count):
            return "Подходов: \(sets), повторений: \(count)"
        case let .duration(seconds):
            let style = Duration.UnitsFormatStyle(allowedUnits: [.minutes, .seconds], width: .wide)
                .locale(Locale(identifier: "ru_RU"))
            return "Подходов: \(sets), по \(Duration.seconds(max(0, seconds)).formatted(style))"
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
            String(format: "%d:%02d", max(0, seconds) / 60, max(0, seconds) % 60)
        }
    }

    /// The small part after the value; durations need none.
    nonisolated var unit: String {
        switch self {
        case .reps: " повт"
        case .duration: ""
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

#Preview("Тёмная, крупный шрифт") {
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
