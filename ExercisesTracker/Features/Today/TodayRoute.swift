import SwiftUI

/// A screen pushed onto the Today tab's stack.
///
/// Models are referred to by `UUID`, not passed in, so a route can also come from a deep link (widget, F7).
/// A destination looks its model up and shows an empty state if it is gone.
enum TodayRoute: Hashable {
    #if DEBUG
        case debug(DebugRoute)
    #endif
}

extension TodayRoute {
    /// The screen for this route. The tab registers this once, so a route without a screen does not compile.
    @ViewBuilder var destination: some View {
        // Release has no routes yet, and an empty `switch` does not compile. With the first real route (2.3)
        // the `switch` moves out and only the `.debug` case stays behind `#if DEBUG`. Until then a Release build
        // warns that `RootView`'s destination closure «will never be executed»: there is no value to call it with.
        #if DEBUG
            switch self {
            case let .debug(route): route.destination
            }
        #endif
    }
}
