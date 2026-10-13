import Foundation
import Testing

struct LocalizationTests {
    /// A new key without a Russian translation, or with mismatched placeholders, fails here rather than on screen.
    @Test func designSystemCatalogIsTranslated() throws {
        let catalog = StringCatalogCheck.catalog("DesignSystem/Resources/Localizable.xcstrings", from: #filePath)

        let problems = try StringCatalogCheck.problems(inCatalogAt: catalog)

        #expect(problems.isEmpty, "\(problems.joined(separator: "\n"))")
    }
}
