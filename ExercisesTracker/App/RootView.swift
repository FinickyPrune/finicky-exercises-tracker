import SwiftUI

struct RootView: View {
    var body: some View {
        NavigationStack {
            #if DEBUG
                if UserDefaults.standard.bool(forKey: "showGallery") {
                    // Launch argument `-showGallery YES` opens the gallery directly, for screenshots.
                    DesignSystemGallery()
                } else {
                    placeholder
                        .toolbar {
                            NavigationLink {
                                DesignSystemGallery()
                            } label: {
                                Label("Design System", systemImage: "paintpalette")
                            }
                        }
                }
            #else
                placeholder
            #endif
        }
    }

    private var placeholder: some View {
        ContentUnavailableView(
            "Exercises Tracker",
            systemImage: "figure.strengthtraining.traditional",
            description: Text("Nothing here yet.")
        )
    }
}

#Preview {
    RootView()
}
