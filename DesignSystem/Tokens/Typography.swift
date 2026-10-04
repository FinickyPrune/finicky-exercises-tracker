import SwiftUI

/// Text styles from docs/DESIGN.md → Типографика. All of them are Dynamic Type styles.
public extension Font {
    nonisolated static let screenTitle = Font.system(.largeTitle, weight: .bold)
    nonisolated static let sectionTitle = Font.system(.title3, weight: .bold)
    /// Routine and exercise names.
    nonisolated static let itemTitle = Font.headline
    /// Status lines under a name: «2 из 6», «Откроет Journal».
    nonisolated static let itemStatus = Font.subheadline
    /// Units next to a plan number: «× », « повт».
    nonisolated static let planUnit = Font.subheadline.weight(.medium)
    /// Capsule button titles.
    nonisolated static let buttonLabel = Font.subheadline.weight(.semibold)
    nonisolated static let timer = Font.system(.largeTitle, design: .rounded, weight: .semibold).monospacedDigit()

    /// Numbers of a plan or fact («15», «0:30»): rounded, semibold.
    nonisolated static func planNumber(_ style: Font.TextStyle = .title3) -> Font {
        .system(style, design: .rounded, weight: .semibold)
    }
}

public extension View {
    /// Uppercase caption with letter spacing: «1 ИЗ 4 · С 7:00».
    func capsLabel() -> some View {
        font(.caption.weight(.semibold))
            .textCase(.uppercase)
            .tracking(1)
    }
}
