#if DEBUG
    import DesignSystem
    import SwiftUI

    struct TypographySamples: View {
        var body: some View {
            let sets = Text("3 × ").font(.planUnit)
            let reps = Text("15").font(.planNumber())
            let done = Text("2").font(.planNumber(.title))
            VStack(alignment: .leading, spacing: Spacing.small) {
                Text(.todayTitle).font(.screenTitle)
                Text(.demoMorning).font(.sectionTitle)
                Text(.galleryProgressFrom(1, 4, "7:00")).capsLabel()
                    .foregroundStyle(Palette.textSecondary)
                Text(.demoGluteBridge).font(.itemTitle)
                Text(.galleryOpensJournal).font(.itemStatus)
                    .foregroundStyle(Palette.textSecondary)
                Text("\(sets)\(reps) \(Text(.galleryRepsUnit))")
                    .font(.planUnit)
                Text("\(done) \(Text(.galleryOfTotal(6)))")
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
                LocalizedStringResource.gallerySpacingScreenEdge(Spacing.screenEdge.formatted()),
                .gallerySpacingSection(Spacing.section.formatted()),
                .gallerySpacingCardGap(Spacing.cardGap.formatted()),
                .gallerySpacingCardPadding(Spacing.cardPadding.formatted()),
            ]
            .map { String(localized: $0) }
            .joined(separator: " · ")
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
                    size(Circle(), Size.button, .galleryShapeButton(Size.button.formatted()))
                    size(Circle(), Size.iconBadge, .galleryShapeIcon(Size.iconBadge.formatted()))
                    size(RoundedRectangle.small, Size.thumbnail, .galleryShapeThumbnail(Size.thumbnail.formatted()))
                }
                VStack(alignment: .leading, spacing: Spacing.xxSmall) {
                    Capsule()
                        .fill(Palette.accent)
                        .frame(height: Size.progressBar)
                    Text(.galleryShapeProgress(Size.progressBar.formatted(), Size.tileMinHeight.formatted()))
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

        /// `title` names the size and includes its value.
        private func size(_ shape: some Shape, _ side: CGFloat, _ title: LocalizedStringResource) -> some View {
            VStack(spacing: Spacing.xxSmall) {
                shape
                    .fill(Palette.surface)
                    .frame(width: side, height: side)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(Palette.textSecondary)
            }
        }
    }
#endif
