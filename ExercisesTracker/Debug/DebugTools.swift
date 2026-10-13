#if DEBUG
    import SwiftUI

    /// Screens only Debug builds can open.
    enum DebugRoute: Hashable {
        case designSystemGallery
    }

    /// Goes on a tab's root screen: a toolbar button to the gallery, and where `DebugRoute` values lead.
    struct DebugTools: ViewModifier {
        func body(content: Content) -> some View {
            content
                .toolbar {
                    NavigationLink(value: DebugRoute.designSystemGallery) {
                        Label("Design System", systemImage: "paintpalette")
                    }
                }
                .navigationDestination(for: DebugRoute.self) { route in
                    Group {
                        switch route {
                        case .designSystemGallery: DesignSystemGallery()
                        }
                    }
                    // Gallery screenshots are reviewed; the tab bar would cover the last rows.
                    .toolbarVisibility(.hidden, for: .tabBar)
                }
        }
    }
#endif
