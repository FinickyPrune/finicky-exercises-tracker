#if DEBUG
import SwiftUI

struct LabExercise: Identifiable {
    enum Plan {
        case reps(sets: Int, reps: Int)
        case time(sets: Int, seconds: Int)

        var sets: Int {
            switch self {
            case let .reps(sets, _), let .time(sets, _): sets
            }
        }

        /// The large part of the plan: «15» or «0:30».
        var value: String {
            switch self {
            case let .reps(_, reps): "\(reps)"
            case let .time(_, seconds): String(format: "%d:%02d", seconds / 60, seconds % 60)
            }
        }

        /// The small unit after the value; time needs none.
        var unit: String {
            switch self {
            case .reps: " повт"
            case .time: ""
            }
        }

        var isTimed: Bool {
            if case .time = self { true } else { false }
        }
    }

    let id: String
    let name: String
    let symbol: String
    let tint: Color
    let plan: Plan
    var isDone: Bool
    /// Actual result when it differs from the plan, e.g. «факт 10 · 8 · 8».
    var factNote: String?
}

struct LabRoutine: Identifiable {
    enum Kind {
        case steps(done: Int, total: Int)
        case link(app: String)
        case check
    }

    let id: String
    let name: String
    let symbol: String
    let tint: Color
    let kind: Kind
    let isDone: Bool
    let isCurrent: Bool

    var status: String {
        if isDone { return "Готово" }
        switch kind {
        case let .steps(done, total): return "\(done) из \(total)"
        case let .link(app): return "Откроет \(app)"
        case .check: return "Отметить"
        }
    }
}

struct LabDayPart: Identifiable {
    let id: String
    let name: String
    let symbol: String
    let tint: LabDayPartTint
    let startTime: String
    let emptyPrompt: String
    let routines: [LabRoutine]

    var doneCount: Int {
        routines.filter(\.isDone).count
    }
}

enum LabDemo {
    static let dayParts = [
        LabDayPart(
            id: "morning", name: "Утро", symbol: "sunrise.fill", tint: LabPalette.morning,
            startTime: "7:00", emptyPrompt: "Что на утро?",
            routines: [
                LabRoutine(
                    id: "workout", name: "Зарядка", symbol: "figure.cooldown", tint: LabPalette.accent,
                    kind: .steps(done: 2, total: 6), isDone: false, isCurrent: true
                ),
                LabRoutine(
                    id: "duolingo", name: "Duolingo", symbol: "bird.fill", tint: LabPalette.sage,
                    kind: .link(app: "Duolingo"), isDone: true, isCurrent: false
                ),
                LabRoutine(
                    id: "journal", name: "Дневник", symbol: "book.closed.fill", tint: LabPalette.plum,
                    kind: .link(app: "Journal"), isDone: false, isCurrent: false
                ),
                LabRoutine(
                    id: "vitamins", name: "Витамины", symbol: "pills.fill", tint: LabPalette.amber,
                    kind: .check, isDone: false, isCurrent: false
                ),
            ]
        ),
        LabDayPart(
            id: "day", name: "День", symbol: "sun.max.fill", tint: LabPalette.day,
            startTime: "12:00", emptyPrompt: "Что сегодня днём?", routines: []
        ),
        LabDayPart(
            id: "evening", name: "Вечер", symbol: "moon.stars.fill", tint: LabPalette.evening,
            startTime: "20:00", emptyPrompt: "Как закончить день?",
            routines: [
                LabRoutine(
                    id: "reading", name: "Чтение", symbol: "books.vertical.fill", tint: LabPalette.coral,
                    kind: .check, isDone: false, isCurrent: false
                ),
            ]
        ),
    ]

    static let exercises = [
        LabExercise(
            id: "squats", name: "Приседания", symbol: "figure.strengthtraining.functional",
            tint: LabPalette.accent, plan: .reps(sets: 3, reps: 15), isDone: true
        ),
        LabExercise(
            id: "pushups", name: "Отжимания", symbol: "figure.strengthtraining.traditional",
            tint: LabPalette.coral, plan: .reps(sets: 3, reps: 10), isDone: true, factNote: "факт 10 · 8 · 8"
        ),
        LabExercise(
            id: "plank", name: "Планка", symbol: "figure.core.training",
            tint: LabPalette.amber, plan: .time(sets: 3, seconds: 30), isDone: false
        ),
        LabExercise(
            id: "lunges", name: "Выпады", symbol: "figure.step.training",
            tint: LabPalette.plum, plan: .reps(sets: 3, reps: 12), isDone: false
        ),
        LabExercise(
            id: "bridge", name: "Ягодичный мост", symbol: "figure.pilates",
            tint: LabPalette.sage, plan: .reps(sets: 3, reps: 15), isDone: false
        ),
        LabExercise(
            id: "stretch", name: "Растяжка", symbol: "figure.flexibility",
            tint: LabPalette.coral, plan: .time(sets: 1, seconds: 90), isDone: false
        ),
    ]
}
#endif
