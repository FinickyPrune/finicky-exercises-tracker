@testable import ExercisesTracker
import SwiftData
import Testing

struct AppModelContainerTests {
    @Test func inMemoryStoresAreSeparate() throws {
        let first = try AppModelContainer.inMemory()
        let second = try AppModelContainer.inMemory()
        let context = ModelContext(first)
        context.insert(Exercise(name: "Приседания"))
        try context.save()

        #expect(try ModelContext(first).fetchCount(FetchDescriptor<Exercise>()) == 1)
        #expect(try ModelContext(second).fetchCount(FetchDescriptor<Exercise>()) == 0)
    }

    /// The test host app opens its store in memory: tests never see the simulator's store on disk.
    @Test func appStoreIsInMemoryUnderTests() throws {
        let container = try AppModelContainer.forApp()

        let inMemory: [Bool] = container.configurations.map(\.isStoredInMemoryOnly)
        #expect(inMemory == [true])
    }
}
