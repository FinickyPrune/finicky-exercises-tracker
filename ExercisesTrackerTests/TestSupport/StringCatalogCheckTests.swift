import Foundation
import Testing

/// The catalog check is the only thing holding the localization rules, so it is tested on small catalogs.
struct StringCatalogCheckTests {
    private func problems(_ strings: [String: Any]) throws -> [String] {
        let catalog: [String: Any] = ["sourceLanguage": "en", "strings": strings, "version": "1.0"]
        return try StringCatalogCheck.problems(inCatalog: JSONSerialization.data(withJSONObject: catalog))
    }

    private func entry(
        english: String = "Today",
        russian: String = "Сегодня",
        comment: String? = "Title.",
        extraction: String? = "manual",
        ruState: String = "translated"
    ) -> [String: Any] {
        var entry: [String: Any] = [
            "localizations": [
                "en": ["stringUnit": ["state": "translated", "value": english]],
                "ru": ["stringUnit": ["state": ruState, "value": russian]],
            ],
        ]
        entry["comment"] = comment
        entry["extractionState"] = extraction
        return entry
    }

    private func plural(_ forms: [String: String]) -> [String: Any] {
        ["variations": ["plural": forms.mapValues { ["stringUnit": ["state": "translated", "value": $0]] }]]
    }

    @Test func completeEntryPasses() throws {
        #expect(try problems(["today": entry()]).isEmpty)
    }

    @Test func missingTranslationFails() throws {
        var today = entry()
        today["localizations"] = ["en": ["stringUnit": ["state": "translated", "value": "Today"]]]

        #expect(try problems(["today": today]) == ["today: no ru"])
    }

    @Test func untranslatedStateFails() throws {
        #expect(try problems(["today": entry(ruState: "needs_review")]) == ["today: ru is not translated"])
    }

    @Test func missingCommentFails() throws {
        #expect(try problems(["today": entry(comment: nil)]) == ["today: no comment for translators"])
    }

    @Test func keyExtractedFromCodeFails() throws {
        #expect(try problems(["today": entry(extraction: nil)]) == ["today: not added by hand (extracted from code)"])
    }

    @Test func reorderedPlaceholdersPass() throws {
        #expect(try problems(["progress": entry(english: "%1$@ of %2$lld", russian: "%2$lld из %1$@")]).isEmpty)
    }

    @Test func differentPlaceholderTypesFail() throws {
        let found = try problems(["distance": entry(english: "%.1f km", russian: "%lld км")])

        #expect(found.count == 1)
        #expect(found.first?.hasPrefix("distance: placeholders differ") == true)
    }

    @Test func substitutionIsRejected() throws {
        let found = try problems(["minutes": entry(english: "%#@count@", russian: "%#@count@")])

        #expect(found.contains { $0.contains("substitution") })
    }

    @Test func russianPluralNeedsEveryForm() throws {
        var minutes = entry()
        minutes["localizations"] = [
            "en": plural(["one": "%lld minute", "other": "%lld minutes"]),
            "ru": plural(["one": "%lld минута", "other": "%lld минуты"]),
        ]

        #expect(try problems(["minutes": minutes]) == ["minutes: ru plural lacks few, many"])
    }

    @Test func completePluralPasses() throws {
        var minutes = entry()
        minutes["localizations"] = [
            "en": plural(["one": "%lld minute", "other": "%lld minutes"]),
            "ru": plural(["one": "%lld минута", "few": "%lld минуты", "many": "%lld минут", "other": "%lld минуты"]),
        ]

        #expect(try problems(["minutes": minutes]).isEmpty)
    }

    @Test(arguments: [
        ("%lld of %lld", [1: "lld", 2: "lld"]),
        ("%2$@ and %1$lld", [1: "lld", 2: "@"]),
        ("%02lld:%02lld", [1: "lld", 2: "lld"]),
        ("%.1f%%", [1: "f"]),
        ("no arguments", [:]),
    ])
    func placeholdersAreTypedByPosition(value: String, expected: [Int: String]) {
        #expect(StringCatalogCheck.placeholders(in: value) == expected)
    }
}
