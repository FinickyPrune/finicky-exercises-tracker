import SwiftUI

/// Dashed slot with a «+» for an empty part of the day: «Что на утро?».
public struct EmptySlot: View {
    private let prompt: String
    private let action: () -> Void

    @ScaledMetric(relativeTo: .body) private var plusSize = Size.button

    public init(_ prompt: String, action: @escaping () -> Void) {
        self.prompt = prompt
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.small) {
                Text(prompt)
                    .foregroundStyle(Palette.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "plus")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Palette.textSecondary)
                    .frame(width: plusSize, height: plusSize)
                    .background(Palette.surface, in: .circle)
            }
            .padding(.leading, Spacing.large)
            .padding(.trailing, Spacing.small)
            .padding(.vertical, Spacing.xSmall)
            .overlay {
                RoundedRectangle.row
                    .strokeBorder(Palette.outline, style: Stroke.dashed)
            }
            .contentShape(.row)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(prompt)
        .accessibilityHint("Добавить рутину")
    }
}

#Preview("Светлая") {
    EmptySlot("Что на утро?") {}
        .padding(Spacing.screenEdge)
        .background(Palette.background)
}

#Preview("Тёмная") {
    EmptySlot("Как закончить день?") {}
        .padding(Spacing.screenEdge)
        .background(Palette.background)
        .preferredColorScheme(.dark)
}
