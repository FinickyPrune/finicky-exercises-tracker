import DesignSystem
import SwiftUI

/// The tab bar. Each tab is a feature's root screen in its own navigation stack.
struct RootView: View {
    @State private var navigation = AppNavigation()

    var body: some View {
        TabView(selection: $navigation.selectedTab) {
            Tab("Сегодня", systemImage: "sun.max", value: AppTab.today) {
                NavigationStack(path: $navigation.todayPath) {
                    TodayView()
                    #if DEBUG
                        .modifier(DebugTools())
                    #endif
                }
            }
        }
        // System controls (the tab bar, toolbar buttons) take the app's accent, not the asset's default blue.
        .tint(Palette.accent)
        .environment(navigation)
    }
}

#Preview {
    RootView()
}
