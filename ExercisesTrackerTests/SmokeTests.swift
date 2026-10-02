@testable import ExercisesTracker
import Testing

struct SmokeTests {
    @Test func rootViewBuilds() {
        _ = RootView().body
    }
}
