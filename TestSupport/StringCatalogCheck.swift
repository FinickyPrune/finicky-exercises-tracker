import Foundation

/// What a String Catalog must hold: every key added by hand, explained for translators,
/// and translated into every app language with the same placeholders.
///
/// Compiled into both test targets (`project.yml`), each checking its own catalog.
nonisolated enum StringCatalogCheck {
    static let languages = ["en", "ru"]

    /// The catalog of a target, found from a test file's `#filePath` two folders below the repository root.
    static func catalog(_ relativePath: String, from testFile: String) -> URL {
        URL(filePath: testFile)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appending(path: relativePath)
    }

    /// One line per problem; empty when the catalog is complete.
    static func problems(inCatalogAt url: URL) throws -> [String] {
        let catalog = try JSONDecoder().decode(Catalog.self, from: Data(contentsOf: url))
        var problems: [String] = []
        if catalog.sourceLanguage != "en" {
            problems.append("source language is \(catalog.sourceLanguage), not en")
        }
        for (key, entry) in catalog.strings.sorted(by: { $0.key < $1.key }) {
            problems += Self.problems(of: entry, key: key)
        }
        return problems
    }

    private static func problems(of entry: Entry, key: String) -> [String] {
        var problems: [String] = []
        if entry.extractionState != "manual" {
            problems.append("\(key): not added by hand (\(entry.extractionState ?? "extracted from code"))")
        }
        if entry.comment?.isEmpty ?? true {
            problems.append("\(key): no comment for translators")
        }
        var placeholders: [String: [String]] = [:]
        for language in languages {
            guard let localization = entry.localizations?[language] else {
                problems.append("\(key): no \(language)")
                continue
            }
            let units = localization.units
            if units.isEmpty {
                problems.append("\(key): \(language) is empty")
            }
            for (variation, unit) in units where unit.state != "translated" || unit.value.isEmpty {
                problems.append("\(key): \(language)\(variation) is not translated")
            }
            placeholders[language] = localization.mainUnit.map { Self.placeholders(in: $0.value) }
        }
        if Set(placeholders.values).count > 1 {
            problems.append("\(key): placeholders differ between languages: \(placeholders)")
        }
        return problems
    }

    /// Format specifiers in order, positions stripped: «%1$lld of %2$@» → [lld, @].
    private static func placeholders(in value: String) -> [String] {
        value.matches(of: #/%(?:\d+\$)?(?<type>lld|ld|d|@|f|%)/#)
            .map { String($0.output.type) }
            .filter { $0 != "%" }
    }

    // MARK: - Format

    private struct Catalog: Decodable {
        let sourceLanguage: String
        let strings: [String: Entry]
    }

    private struct Entry: Decodable {
        let comment: String?
        let extractionState: String?
        let localizations: [String: Localization]?
    }

    private struct Localization: Decodable {
        let stringUnit: StringUnit?
        let variations: Variations?

        /// Every text of this language, named by its variation: «» for a plain string, «.plural.few» and so on.
        var units: [(String, StringUnit)] {
            if let stringUnit {
                return [("", stringUnit)]
            }
            return (variations?.plural ?? [:]).sorted { $0.key < $1.key }.flatMap { name, nested in
                nested.units.map { (".plural.\(name)\($0.0)", $0.1) }
            }
        }

        /// The text whose placeholders are compared: the plain string or the «other» plural form.
        var mainUnit: StringUnit? {
            stringUnit ?? variations?.plural?["other"]?.stringUnit
        }
    }

    private struct Variations: Decodable {
        let plural: [String: Localization]?
    }

    private struct StringUnit: Decodable {
        let state: String
        let value: String
    }
}
