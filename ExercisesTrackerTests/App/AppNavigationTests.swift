@testable import ExercisesTracker
import Foundation
import Testing

struct AppNavigationTests {
    /// Defaults of their own, so launch arguments of the test run do not leak in. Emptied before each test.
    private let defaults: UserDefaults

    init() throws {
        let suite = "AppNavigationTests"
        defaults = try #require(UserDefaults(suiteName: suite))
        defaults.removePersistentDomain(forName: suite)
    }

    @Test func startsOnTodayWithNothingPushed() {
        let navigation = AppNavigation(defaults: defaults)

        #expect(navigation.selectedTab == .today)
        #expect(navigation.todayPath.isEmpty)
    }

    /// Launch arguments arrive as strings: `-showGallery YES`.
    @Test func showGalleryPushesTheGalleryOntoToday() {
        defaults.set("YES", forKey: "showGallery")

        let navigation = AppNavigation(defaults: defaults)

        #expect(navigation.todayPath == [.debug(.designSystemGallery)])
    }
}
