#if DEBUG
    import DesignSystem
    import SwiftUI

    struct TypographySamples: View {
        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.small) {
                Text("Сегодня").font(.screenTitle)
                Text("Утро").font(.sectionTitle)
                Text("1 из 4 · с 7:00").capsLabel()
                    .foregroundStyle(Palette.textSecondary)
                Text("Ягодичный мост").font(.itemTitle)
                Text("Откроет Journal").font(.itemStatus)
                    .foregroundStyle(Palette.textSecondary)
                Text("\(Text("3 × ").font(.planUnit))\(Text("15").font(.planNumber()))\(Text(" повт").font(.planUnit))")
                Text("\(Text("2").font(.planNumber(.title))) из 6")
                    .font(.planUnit)
                Text("0:30").font(.timer)
            }
            .foregroundStyle(Palette.textPrimary)
            .padding(.vertical, Spacing.xSmall)
        }
    }

    struct SpacingSamples: View {
        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.xSmall) {
                ForEach(Spacing.scale, id: \.self) { value in
                    HStack(spacing: Spacing.small) {
                        Text(value.formatted())
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(Palette.textSecondary)
                            .frame(width: Spacing.xxLarge, alignment: .trailing)
                        Rectangle()
                            .fill(Palette.accent)
                            .frame(width: value * 4, height: Spacing.small)
                    }
                }
                Text(semantic)
                    .font(.caption)
                    .foregroundStyle(Palette.textSecondary)
            }
            .padding(.vertical, Spacing.xSmall)
        }

        private var semantic: String {
            [
                "поля экрана \(Spacing.screenEdge.formatted())",
                "между секциями \(Spacing.section.formatted())",
                "между карточками \(Spacing.cardGap.formatted())",
                "внутри карточки \(Spacing.cardPadding.formatted())",
            ].joined(separator: " · ")
        }
    }

    struct ShapeSamples: View {
        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                HStack(spacing: Spacing.small) {
                    sample(.card, "card \(Radius.card.formatted())")
                    sample(.row, "row \(Radius.row.formatted())")
                    sample(.small, "small \(Radius.small.formatted())")
                }
                HStack(alignment: .bottom, spacing: Spacing.medium) {
                    size(Circle(), Size.button, "кнопка")
                    size(Circle(), Size.iconBadge, "иконка")
                    size(RoundedRectangle.small, Size.thumbnail, "миниатюра")
                }
                VStack(alignment: .leading, spacing: Spacing.xxSmall) {
                    Capsule()
                        .fill(Palette.accent)
                        .frame(height: Size.progressBar)
                    Text("Прогресс \(Size.progressBar.formatted()) · плитка от \(Size.tileMinHeight.formatted())")
                        .font(.caption)
                        .foregroundStyle(Palette.textSecondary)
                }
            }
            .padding(.vertical, Spacing.xSmall)
        }

        private func sample(_ shape: RoundedRectangle, _ title: String) -> some View {
            VStack(spacing: Spacing.xxSmall) {
                shape
                    .fill(Palette.surface)
                    .frame(width: 88, height: 64)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(Palette.textSecondary)
            }
        }

        private func size(_ shape: some Shape, _ side: CGFloat, _ title: String) -> some View {
            VStack(spacing: Spacing.xxSmall) {
                shape
                    .fill(Palette.surface)
                    .frame(width: side, height: side)
                Text("\(title) \(side.formatted())")
                    .font(.caption)
                    .foregroundStyle(Palette.textSecondary)
            }
        }
    }
#endif
