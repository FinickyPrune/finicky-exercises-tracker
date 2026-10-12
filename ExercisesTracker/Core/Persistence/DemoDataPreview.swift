#if DEBUG
    import SwiftData
    import SwiftUI

    extension PreviewTrait where T == Preview.ViewTraits {
        /// `#Preview(traits: .demoData)`: an in-memory store with «моё утро».
        /// Views read it with `@Query` or through `SwiftDataRoutineStore(context: modelContext)`.
        static var demoData: Self {
            .modifier(DemoDataPreview())
        }
    }

    private struct DemoDataPreview: PreviewModifier {
        static func makeSharedContext() throws -> ModelContainer {
            let container = try AppModelContainer.inMemory()
            try DemoData.insert(into: container.mainContext)
            return container
        }

        func body(content: Content, context: ModelContainer) -> some View {
            content.modelContainer(context)
        }
    }

    /// What the demo store holds.
    private struct DemoDataList: View {
        @Query(sort: \DayPart.sortIndex) private var dayParts: [DayPart]

        var body: some View {
            List(dayParts) { dayPart in
                Section(dayPart.name) {
                    ForEach(dayPart.orderedRoutines) { routine in
                        Text(routine.name)
                    }
                }
            }
        }
    }

    #Preview(traits: .demoData) {
        DemoDataList()
    }
#endif
