import Foundation
import SwiftData

/// SwiftData containers for the latest schema version, with its migration plan.
enum AppModelContainer {
    /// The app's store on disk.
    ///
    /// Under unit tests the host app gets an empty in-memory store instead: tests never read the simulator's
    /// store, and a store left from an older v1 (it still changes before the first release) cannot crash them.
    static func forApp() throws -> ModelContainer {
        #if DEBUG
            if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
                return try inMemory()
            }
        #endif
        return try make(ModelConfiguration())
    }

    /// An empty store in memory, for tests and previews. Each call makes a separate store.
    static func inMemory() throws -> ModelContainer {
        try make(ModelConfiguration(isStoredInMemoryOnly: true))
    }

    private static func make(_ configuration: ModelConfiguration) throws -> ModelContainer {
        try ModelContainer(
            for: Schema(versionedSchema: SchemaV1.self),
            migrationPlan: AppMigrationPlan.self,
            configurations: configuration
        )
    }
}
