#if DEBUG
    import DesignSystem
    import SwiftUI

    /// Debug-only catalog of every design-system token. Review of design changes goes by its screenshots.
    ///
    /// Launch arguments for screenshots: `-showGallery YES` opens it (see `AppNavigation`),
    /// `-gallerySection <id>` scrolls to a section: headers, cards, controls, feedback, colors, contrast, dayParts,
    /// routines, typography, spacing, shapes.
    struct DesignSystemGallery: View {
        @State private var celebrating = false

        var body: some View {
            ScrollViewReader { proxy in
                List {
                    Section(.gallerySectionHeaders) {
                        HeaderSamples()
                    }
                    .id("headers")
                    Section(.gallerySectionCards) {
                        CardSamples()
                    }
                    .id("cards")
                    Section(.gallerySectionControls) {
                        ControlSamples()
                    }
                    .id("controls")
                    Section {
                        FeedbackSamples(celebrating: $celebrating)
                    } header: {
                        Text(.gallerySectionFeedback)
                    } footer: {
                        Text(.galleryFeedbackFooter)
                    }
                    .id("feedback")
                    Section(.gallerySectionColors) {
                        ForEach(Palette.all) { token in
                            ColorTokenRow(token: token)
                        }
                    }
                    .id("colors")
                    Section {
                        ForEach(ContrastPair.all) { pair in
                            ContrastPairRow(pair: pair)
                        }
                    } header: {
                        Text(.gallerySectionContrast)
                    } footer: {
                        Text(.galleryContrastFooter)
                    }
                    .id("contrast")
                    Section(.gallerySectionDayParts) {
                        ForEach(DayPartTint.all, id: \.name) { tint in
                            DayPartTintRow(tint: tint)
                        }
                    }
                    .id("dayParts")
                    Section(.gallerySectionRoutineTints) {
                        ForEach(RoutineTint.allCases, id: \.self) { tint in
                            ColorTokenRow(token: tint.token)
                        }
                    }
                    .id("routines")
                    Section(.gallerySectionTypography) {
                        TypographySamples()
                    }
                    .id("typography")
                    Section(.gallerySectionSpacing) {
                        SpacingSamples()
                    }
                    .id("spacing")
                    Section(.gallerySectionShapes) {
                        ShapeSamples()
                    }
                    .id("shapes")
                }
                .scrollContentBackground(.hidden)
                .background(Palette.background)
                .overlay { CelebrationOverlay(isPresented: $celebrating) }
                .navigationTitle(.galleryTitle)
                .onAppear {
                    if let section = UserDefaults.standard.string(forKey: "gallerySection") {
                        proxy.scrollTo(section, anchor: .top)
                    }
                }
            }
        }
    }

    #Preview {
        NavigationStack { DesignSystemGallery() }
    }
#endif
