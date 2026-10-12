import SwiftData
import SwiftUI

@main
struct ExercisesTrackerApp: App {
    private let container: ModelContainer

    init() {
        do {
            container = try AppModelContainer.forApp()
        } catch {
            // Until the first release v1 still changes, and a store from an older build may not open:
            // delete the app from the device to start over.
            fatalError("Cannot open the store: \(error)")
        }
        #if DEBUG
            do {
                try DemoData.insertIfEmpty(into: container.mainContext)
            } catch {
                assertionFailure("Cannot insert demo data: \(error)")
            }
        #endif
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(container)
    }
}
