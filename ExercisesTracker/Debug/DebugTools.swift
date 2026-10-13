#if DEBUG
    import SwiftUI

    /// Screens only Debug builds can open. A tab's route wraps them: `TodayRoute.debug(_:)`.
    enum DebugRoute: Hashable {
        case designSystemGallery

        @ViewBuilder var destination: some View {
            switch self {
            case .designSystemGallery:
                DesignSystemGallery()
                    // Gallery screenshots are reviewed; the tab bar would cover the last rows.
                    .toolbarVisibility(.hidden, for: .tabBar)
            }
        }
    }

    /// Goes on the Today tab's root screen: a toolbar button to the gallery.
    /// On the leading side, so the trailing one stays for the screen's own actions (2.4, F4).
    struct DebugTools: ViewModifier {
        func body(content: Content) -> some View {
            content
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        NavigationLink(value: TodayRoute.debug(.designSystemGallery)) {
                            Label(.galleryTitle, systemImage: "paintpalette")
                        }
                    }
                }
        }
    }
#endif
