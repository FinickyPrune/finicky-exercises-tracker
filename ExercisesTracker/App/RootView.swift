import SwiftUI

struct RootView: View {
    var body: some View {
        #if DEBUG
            // Temporary while the visual direction is chosen (task 0.1).
            DesignLabView()
        #else
            ContentUnavailableView(
                "Exercises Tracker",
                systemImage: "figure.strengthtraining.traditional",
                description: Text("Nothing here yet.")
            )
        #endif
    }
}

#Preview {
    RootView()
}
