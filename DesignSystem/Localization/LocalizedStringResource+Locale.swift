import Foundation

public extension LocalizedStringResource {
    /// The text in `locale`: a view's environment locale, or a fixed one in tests.
    nonisolated func string(in locale: Locale) -> String {
        var resource = self
        resource.locale = locale
        return String(localized: resource)
    }
}
