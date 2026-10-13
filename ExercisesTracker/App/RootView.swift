import SwiftUI

/// The tab bar. Each tab is a feature's root screen in its own navigation stack.
struct RootView: View {
    @State private var navigation = AppNavigation()

    var body: some View {
        TabView(selection: $navigation.selectedTab) {
            Tab(.tabToday, systemImage: "sun.max", value: AppTab.today) {
                NavigationStack(path: $navigation.todayPath) {
                    TodayView()
                        .navigationDestination(for: TodayRoute.self) { $0.destination }
                    #if DEBUG
                        .modifier(DebugTools())
                    #endif
                }
            }
        }
    }
}

#Preview {
    RootView()
}
