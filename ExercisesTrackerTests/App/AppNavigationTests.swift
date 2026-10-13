@testable import ExercisesTracker
import Foundation
import SwiftUI
import Testing

struct AppNavigationTests {
    /// Defaults of their own, so launch arguments of the test run do not leak in.
    private let defaults: UserDefaults

    init() throws {
        let suite = "AppNavigationTests.\(UUID().uuidString)"
        defaults = try #require(UserDefaults(suiteName: suite))
        defaults.removePersistentDomain(forName: suite)
    }

    @Test func startsOnTodayWithNothingPushed() {
        let navigation = AppNavigation(launchArguments: defaults)

        #expect(navigation.selectedTab == .today)
        #expect(navigation.todayPath.isEmpty)
    }

    @Test func showGalleryPushesTheGalleryOntoToday() {
        defaults.set(true, forKey: "showGallery")

        let navigation = AppNavigation(launchArguments: defaults)

        #expect(navigation.todayPath == NavigationPath([DebugRoute.designSystemGallery]))
    }
}
