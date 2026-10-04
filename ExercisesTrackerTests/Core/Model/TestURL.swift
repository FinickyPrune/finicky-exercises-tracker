import Foundation

/// A URL from a literal that is known to be valid; avoids force unwraps in tests.
nonisolated func testURL(_ string: String) -> URL {
    guard let url = URL(string: string) else {
        preconditionFailure("Invalid test URL: \(string)")
    }
    return url
}
