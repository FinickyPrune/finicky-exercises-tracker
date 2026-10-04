@testable import ExercisesTracker
import Testing

struct SmokeTests {
    @Test func rootViewBuilds() {
        _ = RootView().body
    }

    #if DEBUG
        @Test func galleryBuilds() {
            _ = DesignSystemGallery().body
        }
    #endif
}
