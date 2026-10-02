import SwiftUI

struct RootView: View {
    var body: some View {
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
