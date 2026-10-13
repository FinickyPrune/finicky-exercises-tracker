import Foundation

/// What a String Catalog must hold: every key added by hand, explained for translators,
/// and translated into every app language with the same placeholders and all plural forms.
///
/// Compiled into both test targets (`project.yml`), each checking its own catalog.
nonisolated enum StringCatalogCheck {
    /// The app's languages. A new language is added here, to `pluralCategories` and to both catalogs.
    static let languages = ["en", "ru"]

    /// Plural forms each language needs (CLDR): Russian has «1 минута», «2 минуты», «5 минут» and fractions.
    static let pluralCategories = ["en": ["one", "other"], "ru": ["few", "many", "one", "other"]]

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
        try problems(inCatalog: Data(contentsOf: url))
    }

    /// One line per problem in the catalog's JSON; empty when it is complete.
    static func problems(inCatalog data: Data) throws -> [String] {
        let catalog = try JSONDecoder().decode(Catalog.self, from: data)
        var problems: [String] = []
        if catalog.sourceLanguage != "en" {
            problems.append("source language is \(catalog.sourceLanguage), not en")
        }
        for (key, entry) in catalog.strings.sorted(by: { $0.key < $1.key }) {
            problems += Self.problems(of: entry, key: key)
        }
        return problems
    }

    /// The type of each argument by its position, so a translation may reorder them:
    /// «%1$@ of %2$lld» and «%2$lld из %1$@» are both [1: @, 2: lld]. Width and precision are not compared.
    static func placeholders(in value: String) -> [Int: String] {
        var types: [Int: String] = [:]
        var next = 1
        let specifier = #/
            % (?: (?<position> \d+ ) \$ )?                         # position: %2$
            [\-+\x20\#0']* \d* (?: \. \d+ )?                       # flags, width, precision
            (?<type> (?: hh|h|ll|l|q|z|t|j|L )? [@dDiuUxXoOfFeEgGaAcCsSp%] )
            /#
        for match in value.matches(of: specifier) where match.output.type != "%" {
            let position = match.output.position.flatMap { Int($0) } ?? next
            types[position] = String(match.output.type)
            next = position + 1
        }
        return types
    }

    private static func problems(of entry: Entry, key: String) -> [String] {
        var problems: [String] = []
        if entry.extractionState != "manual" {
            problems.append("\(key): not added by hand (\(entry.extractionState ?? "extracted from code"))")
        }
        if entry.comment?.isEmpty ?? true {
            problems.append("\(key): no comment for translators")
        }
        var placeholders: [String: [Int: String]] = [:]
        for language in languages {
            guard let localization = entry.localizations?[language] else {
                problems.append("\(key): no \(language)")
                continue
            }
            problems += Self.problems(of: localization, key: key, language: language)
            placeholders[language] = localization.mainUnit.map { Self.placeholders(in: $0.value) }
        }
        if Set(placeholders.values).count > 1 {
            problems.append("\(key): placeholders differ between languages: \(placeholders)")
        }
        return problems
    }

    private static func problems(of localization: Localization, key: String, language: String) -> [String] {
        var problems: [String] = []
        let units = localization.units
        if units.isEmpty {
            problems.append("\(key): \(language) is empty")
        }
        for (variation, unit) in units {
            if unit.state != "translated" || unit.value.isEmpty {
                problems.append("\(key): \(language)\(variation) is not translated")
            }
            if unit.value.contains("%#@") {
                problems.append("\(key): \(language)\(variation) uses a %#@…@ substitution; this check cannot read it")
            }
        }
        if let plural = localization.variations?.plural {
            let missing = Set(pluralCategories[language] ?? []).subtracting(plural.keys)
            if !missing.isEmpty {
                problems.append("\(key): \(language) plural lacks \(missing.sorted().joined(separator: ", "))")
            }
        }
        return problems
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
