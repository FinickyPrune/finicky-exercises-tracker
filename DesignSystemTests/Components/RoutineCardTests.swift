@testable import DesignSystem
import SwiftUI
import Testing

struct RoutineCardTests {
    @Test func pendingReadsStatus() {
        #expect(RoutineCard.accessibilityValue(state: .pending, status: "Отметить") == "Отметить")
    }

    @Test func currentIsAnnounced() {
        #expect(RoutineCard.accessibilityValue(state: .current, status: "2 из 6") == "Сейчас, 2 из 6")
    }

    @Test func doneReadsAsDone() {
        #expect(RoutineCard.accessibilityValue(state: .done, status: "Готово") == "Выполнено")
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
