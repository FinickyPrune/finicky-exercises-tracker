#if DEBUG
    import DesignSystem
    import SwiftUI

    /// Debug-only catalog of every design-system token. Review of design changes goes by its screenshots.
    ///
    /// Launch arguments for screenshots: `-showGallery YES` opens it (see `RootView`),
    /// `-gallerySection <id>` scrolls to a section: colors, contrast, dayParts, routines, typography, spacing, shapes.
    struct DesignSystemGallery: View {
        var body: some View {
            ScrollViewReader { proxy in
                List {
                    Section("Цвета") {
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
                        Text("Контраст")
                    } footer: {
                        Text("Светлая · тёмная, затем с повышенным контрастом (HC). Минимум: 4,5 — текст, 3 — значки.")
                    }
                    .id("contrast")
                    Section("Части дня") {
                        ForEach(DayPartTint.all, id: \.name) { tint in
                            DayPartTintRow(tint: tint)
                        }
                    }
                    .id("dayParts")
                    Section("Палитра рутин") {
                        ForEach(RoutineTint.allCases, id: \.self) { tint in
                            ColorTokenRow(token: tint.token)
                        }
                    }
                    .id("routines")
                    Section("Типографика") {
                        TypographySamples()
                    }
                    .id("typography")
                    Section("Отступы") {
                        SpacingSamples()
                    }
                    .id("spacing")
                    Section("Радиусы и размеры") {
                        ShapeSamples()
                    }
                    .id("shapes")
                }
                .scrollContentBackground(.hidden)
                .background(Palette.background)
                .navigationTitle("Design System")
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
