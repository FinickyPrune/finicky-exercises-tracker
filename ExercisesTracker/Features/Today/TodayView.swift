import SwiftUI

/// The Today tab: the parts of the day and their routines. A placeholder until 2.1.
struct TodayView: View {
    var body: some View {
        ContentUnavailableView {
            Label(.todayEmptyTitle, systemImage: "sun.max")
        } description: {
            Text(.todayEmptyDescription)
        }
        .navigationTitle(.todayTitle)
    }
}

#Preview {
    NavigationStack {
        TodayView()
    }
}
