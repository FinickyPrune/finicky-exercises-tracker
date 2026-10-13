@testable import DesignSystem
import Foundation
import Testing

struct LocalizedStringResourceTests {
    @Test(arguments: [("en", "reps"), ("ru", "повт"), ("ru_US", "повт")])
    func textFollowsTheLocale(identifier: String, expected: String) {
        #expect(LocalizedStringResource.planRepsUnit.string(in: Locale(identifier: identifier)) == expected)
    }

    /// English is the base language: a device in a language the app lacks gets English.
    @Test(arguments: ["fr", "de_DE", "sr", "uk"])
    func unsupportedLanguageFallsBackToEnglish(identifier: String) {
        #expect(LocalizedStringResource.planRepsUnit.string(in: Locale(identifier: identifier)) == "reps")
    }
}
