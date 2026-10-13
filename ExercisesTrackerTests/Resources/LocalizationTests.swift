import Foundation
import Testing

struct LocalizationTests {
    /// A new key without a Russian translation, or with mismatched placeholders, fails here rather than on screen.
    @Test func appCatalogIsTranslated() throws {
        let catalog = StringCatalogCheck.catalog("ExercisesTracker/Resources/Localizable.xcstrings", from: #filePath)

        let problems = try StringCatalogCheck.problems(inCatalogAt: catalog)

        #expect(problems.isEmpty, "\(problems.joined(separator: "\n"))")
    }
}
