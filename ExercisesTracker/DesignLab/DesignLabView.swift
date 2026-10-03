#if DEBUG
import SwiftUI

/// Entry point of the 0.1 lab. Launch arguments open a screen directly, for screenshots:
/// `-labVariant a|b|c -labScreen today|workout`.
struct DesignLabView: View {
    var body: some View {
        NavigationStack {
            if let style = launchStyle {
                if UserDefaults.standard.string(forKey: "labScreen") == "workout" {
                    LabWorkoutView(style: style)
                } else {
                    LabTodayView(style: style)
                }
            } else {
                variantList
            }
        }
        .tint(LabPalette.accent)
    }

    private var launchStyle: LabStyle? {
        let id = UserDefaults.standard.string(forKey: "labVariant")
        return LabStyle.all.first { $0.id == id }
    }

    private var variantList: some View {
        List(LabStyle.all) { style in
            Section(style.name) {
                Text(style.summary)
                    .foregroundStyle(.secondary)
                NavigationLink("Сегодня") { LabTodayView(style: style) }
                NavigationLink("Зарядка") { LabWorkoutView(style: style) }
            }
        }
        .navigationTitle("Design Lab")
    }
}

#Preview {
    DesignLabView()
}
#endif
