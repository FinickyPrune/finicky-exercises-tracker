import SwiftUI

/// The app's tabs, in tab bar order. A new tab is a case here, a `Tab` in `RootView` and a path below.
enum AppTab: Hashable {
    case today
}

/// Where the user is: the selected tab and what is pushed onto each tab's stack.
///
/// Screens open by value: a route appended to a path. So the app itself or a deep link (widget, F7) can open
/// a screen without a tap. `RootView` owns this and puts it in the environment.
@Observable
final class AppNavigation {
    var selectedTab: AppTab = .today
    /// The Today tab's stack above its root screen.
    var todayPath = NavigationPath()

    /// `defaults` carries the launch arguments: `-showGallery YES` opens the design-system gallery, for screenshots.
    init(launchArguments defaults: UserDefaults = .standard) {
        #if DEBUG
            if defaults.bool(forKey: "showGallery") {
                todayPath.append(DebugRoute.designSystemGallery)
            }
        #endif
    }
}
