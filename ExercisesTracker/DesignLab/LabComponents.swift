#if DEBUG
import SwiftUI

struct LabIconBadge: View {
    let symbol: String
    let tint: Color
    var onAccent = false

    @ScaledMetric private var size = 40.0

    var body: some View {
        Image(systemName: symbol)
            .font(.body.weight(.semibold))
            .foregroundStyle(onAccent ? LabPalette.onAccent : tint)
            .frame(width: size, height: size)
            .background(onAccent ? LabPalette.onAccent.opacity(0.22) : tint.opacity(0.16), in: .circle)
    }
}

struct LabCheckButton: View {
    let isOn: Bool
    var onAccent = false
    let action: () -> Void

    @ScaledMetric private var size = 44.0

    var body: some View {
        Button(action: action) {
            Image(systemName: "checkmark")
                .font(.body.weight(.bold))
                .foregroundStyle(foreground)
                .frame(width: size, height: size)
                .background(background, in: .circle)
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isOn ? "Выполнено" : "Отметить по плану")
    }

    private var foreground: Color {
        if onAccent { return isOn ? LabPalette.accent : LabPalette.onAccent }
        return isOn ? LabPalette.onAccent : LabPalette.textSecondary.opacity(0.5)
    }

    private var background: Color {
        if onAccent { return isOn ? LabPalette.onAccent : LabPalette.onAccent.opacity(0.22) }
        return isOn ? LabPalette.accent : LabPalette.surfaceRaised
    }
}

struct LabCapsuleButton: View {
    enum Kind {
        case accent
        case dark
        case onAccent
    }

    let title: String
    var kind = Kind.accent
    var fullWidth = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(foreground)
                .padding(.horizontal, 16)
                .padding(.vertical, fullWidth ? 16 : 10)
                .frame(maxWidth: fullWidth ? .infinity : nil)
                .background(background, in: .capsule)
        }
        .buttonStyle(.plain)
    }

    private var foreground: Color {
        switch kind {
        case .accent: LabPalette.onAccent
        case .dark: LabPalette.background
        case .onAccent: LabPalette.accent
        }
    }

    private var background: Color {
        switch kind {
        case .accent: LabPalette.accent
        case .dark: LabPalette.textPrimary
        case .onAccent: LabPalette.onAccent
        }
    }
}

/// «3 × 15 повт», «3 × 0:30»: the number is large, the rest is small.
struct LabPlanText: View {
    let plan: LabExercise.Plan
    var size = Font.TextStyle.title3

    var body: some View {
        let small = Font.subheadline.weight(.medium)
        let sets = Text("\(plan.sets) × ").font(small)
        let value = Text(plan.value).font(LabFont.number(size))
        let unit = Text(plan.unit).font(small)
        Text("\(sets)\(value)\(unit)")
            .monospacedDigit()
    }
}

/// Tiimo-style day part header: tinted capsule with icon, caps title and counter.
struct LabDayPartCapsule: View {
    let part: LabDayPart

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: part.symbol)
                .foregroundStyle(part.tint.icon)
            Text(part.routines.isEmpty ? part.name : "\(part.name) (\(part.doneCount)/\(part.routines.count))")
                .labCaps()
            Image(systemName: "chevron.down")
                .font(.caption.weight(.bold))
                .foregroundStyle(LabPalette.textSecondary)
        }
        .foregroundStyle(LabPalette.textPrimary)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(part.tint.background, in: .capsule)
    }
}

/// Gentler-style day part header: bold section title with a caps subtitle.
struct LabDayPartSection: View {
    let part: LabDayPart

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(part.name)
                .font(LabFont.sectionTitle)
                .foregroundStyle(LabPalette.textPrimary)
            Text(part.routines.isEmpty
                ? "с \(part.startTime)"
                : "\(part.doneCount) из \(part.routines.count) · с \(part.startTime)")
                .labCaps()
                .foregroundStyle(LabPalette.textSecondary)
        }
    }
}

struct LabEmptySlot: View {
    let prompt: String

    var body: some View {
        HStack {
            Text(prompt)
                .foregroundStyle(LabPalette.textSecondary)
            Spacer()
            Image(systemName: "plus")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(LabPalette.textSecondary)
                .padding(8)
                .background(LabPalette.surface, in: .circle)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(LabPalette.outline, style: StrokeStyle(lineWidth: 1.5, dash: [6, 5]))
        }
    }
}

struct LabProgressBar: View {
    let value: Double
    var tint = LabPalette.accent
    var track = LabPalette.surface

    var body: some View {
        GeometryReader { proxy in
            Capsule()
                .fill(track)
                .overlay(alignment: .leading) {
                    Capsule()
                        .fill(tint)
                        .frame(width: proxy.size.width * value)
                }
        }
        .frame(height: 8)
    }
}
#endif
