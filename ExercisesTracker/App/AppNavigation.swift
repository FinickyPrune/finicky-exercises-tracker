import SwiftUI

/// The app's tabs, in tab bar order. A new tab is a case here, a `Tab` in `RootView` and a path below.
enum AppTab: Hashable {
    case today
}

/// Where the user is: the selected tab and what is pushed onto each tab's stack.
///
/// Screens push with `NavigationLink(value:)`. Code changes a path only for deep links and system events,
/// through methods added here when they appear (F7): they see the top of the stack and do not push a screen twice.
@Observable
final class AppNavigation {
    var selectedTab: AppTab = .today
    /// The Today tab's stack above its root screen.
    var todayPath: [TodayRoute] = []

    /// `defaults` carries the launch arguments: `-showGallery YES` opens the design-system gallery, for screenshots.
    init(defaults: UserDefaults = .standard) {
        #if DEBUG
            if defaults.bool(forKey: "showGallery") {
                todayPath = [.debug(.designSystemGallery)]
            }
        #endif
    }
}
