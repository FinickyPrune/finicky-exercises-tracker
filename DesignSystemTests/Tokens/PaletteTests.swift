@testable import DesignSystem
import SwiftUI
import Testing

/// Contrast guarantees from docs/DESIGN.md. A token change that breaks one of them fails here.
struct PaletteTests {
    /// `nonisolated`: `@Test(arguments:)` reads it outside the main actor.
    nonisolated private static let schemes: [ColorScheme] = [.light, .dark]

    private func ratio(
        _ foreground: ColorToken,
        on background: ColorToken,
        _ scheme: ColorScheme,
        _ contrast: ColorSchemeContrast = .standard
    ) -> Double {
        Contrast.ratio(
            foreground.hex(for: scheme, contrast: contrast),
            background.hex(for: scheme, contrast: contrast)
        )
    }

    @Test(arguments: schemes)
    func primaryTextIsReadableOnBackgroundAndCards(scheme: ColorScheme) {
        #expect(ratio(Palette.textPrimary, on: Palette.background, scheme) >= Contrast.text)
        #expect(ratio(Palette.textPrimary, on: Palette.surface, scheme) >= Contrast.text)
        #expect(ratio(Palette.textPrimary, on: Palette.surfaceRaised, scheme) >= Contrast.text)
    }

    @Test(arguments: schemes)
    func increasedContrastMakesTextOnAccentReadable(scheme: ColorScheme) {
        #expect(ratio(Palette.onAccent, on: Palette.accent, scheme, .increased) >= Contrast.text)
    }

    /// The accent stays readable as text on every surface it can sit on, so it may also color small labels.
    @Test(arguments: schemes)
    func increasedContrastMakesAccentReadableOnSurfaces(scheme: ColorScheme) {
        for surface in [Palette.background, Palette.surface, Palette.surfaceRaised] {
            #expect(ratio(Palette.accent, on: surface, scheme, .increased) >= Contrast.text, "\(surface.name)")
        }
    }

    @Test(arguments: schemes)
    func increasedContrastMakesSecondaryTextReadable(scheme: ColorScheme) {
        #expect(ratio(Palette.textSecondary, on: Palette.surface, scheme, .increased) >= Contrast.text)
    }

    @Test(arguments: schemes)
    func uncheckedCheckmarkIsVisible(scheme: ColorScheme) {
        #expect(ratio(Palette.textSecondary, on: Palette.surfaceRaised, scheme) >= Contrast.large)
    }

    @Test func tokenNamesAreUnique() {
        let names = Palette.all.map(\.name)
        #expect(Set(names).count == names.count)
    }

    @Test func routinePaletteHasEightDistinctColors() {
        let values = RoutineTint.allCases.map(\.token.light)
        #expect(values.count == 8)
        #expect(Set(values).count == values.count)
    }

    /// Raw values are persisted with routines; renaming a case would lose the user's choice.
    @Test func routineTintRawValuesAreStable() {
        #expect(RoutineTint.allCases.map(\.rawValue) == [
            "orange", "coral", "amber", "terracotta", "pink", "plum", "sage", "sand",
        ])
    }

    @Test(arguments: [RoutineTint.orange.token, DayPartTint.morning.icon])
    func accentCopiesFollowAccentEverywhere(token: ColorToken) {
        for scheme in Self.schemes {
            for contrast in [ColorSchemeContrast.standard, .increased] {
                let expected = Palette.accent.hex(for: scheme, contrast: contrast)
                #expect(token.hex(for: scheme, contrast: contrast) == expected)
            }
        }
    }
}
