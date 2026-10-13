@testable import DesignSystem
import SwiftUI
import Testing

struct RoutineCardTests {
    private nonisolated static let english = Locale(identifier: "en")
    private nonisolated static let russian = Locale(identifier: "ru")

    @Test func pendingReadsStatus() {
        let value = RoutineCard.accessibilityValue(state: .pending, status: "Check off", locale: Self.english)
        #expect(value == "Check off")
    }

    @Test(arguments: [(english, "2 of 6", "Now, 2 of 6"), (russian, "2 из 6", "Сейчас, 2 из 6")])
    func currentIsAnnounced(locale: Locale, status: String, expected: String) {
        #expect(RoutineCard.accessibilityValue(state: .current, status: status, locale: locale) == expected)
    }

    @Test(arguments: [(english, "at 7:40", "Done, at 7:40"), (russian, "в 7:40", "Выполнено, в 7:40")])
    func doneKeepsStatus(locale: Locale, status: String, expected: String) {
        #expect(RoutineCard.accessibilityValue(state: .done, status: status, locale: locale) == expected)
    }
}

struct RoutineGridTests {
    @Test(arguments: [DynamicTypeSize.xSmall, .large, .xxxLarge])
    func twoColumnsAtRegularSizes(size: DynamicTypeSize) {
        #expect(RoutineGrid<EmptyView>.columnCount(for: size) == 2)
    }

    @Test(arguments: [DynamicTypeSize.accessibility1, .accessibility5])
    func oneColumnAtAccessibilitySizes(size: DynamicTypeSize) {
        #expect(RoutineGrid<EmptyView>.columnCount(for: size) == 1)
    }
}
