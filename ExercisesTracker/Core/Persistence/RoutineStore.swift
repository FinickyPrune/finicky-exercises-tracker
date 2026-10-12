import Foundation
import SwiftData

/// Reads and writes of templates and history. Screens go through it, so the storage can change
/// without touching them (docs/ARCHITECTURE.md → Хранилище).
///
/// Templates are edited in place: change the objects, then call `save()`. History is written by the run methods,
/// and they save right away, so a recorded set is not lost if the app is closed.
protocol RoutineStore {
    // MARK: Templates

    /// Parts of the day in display order; their routines in order are `orderedRoutines`.
    func dayParts() throws -> [DayPart]

    /// The exercise library by name, archived exercises included.
    func exercises() throws -> [Exercise]

    /// Adds a part of the day, routine, step or exercise. A routine or step appended to its parent
    /// is inserted together with the parent and does not need this.
    func insert(_ model: some TemplateModel)

    /// Removes a template. A part of the day or a routine takes what is inside with it;
    /// deleting an exercise keeps the steps and history that used it.
    func delete(_ model: some TemplateModel)

    /// Writes changes to templates.
    func save() throws

    // MARK: History

    /// Runs started on the day `date` falls on, oldest first.
    func runs(on date: Date) throws -> [RoutineRun]

    /// The run of `routine` started on the same day as `date`, or a new one if there is none yet,
    /// so coming back to a routine continues it instead of starting over.
    func startOrResumeRun(of routine: Routine, at date: Date) throws -> RoutineRun

    /// Records what was done for one step (`nil` takes it back) and saves.
    func record(_ actual: StepActual?, for result: StepResult, at date: Date) throws

    /// «По плану» in one tap, saved.
    func recordAsPlanned(_ result: StepResult, at date: Date) throws
}

/// A model of the template graph: the only kind `RoutineStore.insert` and `delete` take.
/// History changes only through the run methods.
protocol TemplateModel: PersistentModel {}

extension DayPart: TemplateModel {}
extension Routine: TemplateModel {}
extension Step: TemplateModel {}
extension Exercise: TemplateModel {}

/// `RoutineStore` on a SwiftData context, usually the container's `mainContext`.
struct SwiftDataRoutineStore: RoutineStore {
    private let context: ModelContext
    /// Decides which day a date falls on.
    private let calendar: Calendar

    init(context: ModelContext, calendar: Calendar = .autoupdatingCurrent) {
        self.context = context
        self.calendar = calendar
    }

    func dayParts() throws -> [DayPart] {
        try context.fetch(FetchDescriptor(sortBy: [SortDescriptor(\.sortIndex)]))
    }

    func exercises() throws -> [Exercise] {
        // Sorted here, the way Finder sorts names, so «планка» comes before «Приседания». The library is small.
        try context.fetch(FetchDescriptor<Exercise>())
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    func insert(_ model: some TemplateModel) {
        context.insert(model)
    }

    func delete(_ model: some TemplateModel) {
        context.delete(model)
    }

    func save() throws {
        try context.save()
    }

    func runs(on date: Date) throws -> [RoutineRun] {
        let dayKey = DayKey.of(date, in: calendar)
        return try context.fetch(FetchDescriptor(
            predicate: #Predicate { $0.dayKey == dayKey },
            sortBy: [SortDescriptor(\.startedAt)]
        ))
    }

    func startOrResumeRun(of routine: Routine, at date: Date) throws -> RoutineRun {
        let dayKey = DayKey.of(date, in: calendar)
        let routineID = routine.id
        var started = FetchDescriptor<RoutineRun>(
            predicate: #Predicate { $0.routineID == routineID && $0.dayKey == dayKey },
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )
        started.fetchLimit = 1
        if let run = try context.fetch(started).first {
            return run
        }
        let run = RoutineRun.start(routine, at: date, calendar: calendar)
        context.insert(run)
        try context.save()
        return run
    }

    func record(_ actual: StepActual?, for result: StepResult, at date: Date) throws {
        try result.record(actual, at: date)
        try context.save()
    }

    func recordAsPlanned(_ result: StepResult, at date: Date) throws {
        try result.recordAsPlanned(at: date)
        try context.save()
    }
}
