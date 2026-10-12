import Foundation
import SwiftData

// Code outside Core/Model uses these names; they point at the latest schema version (now v1).
typealias DayPart = SchemaV1.DayPart
typealias Routine = SchemaV1.Routine
typealias Step = SchemaV1.Step
typealias Exercise = SchemaV1.Exercise
typealias RoutineRun = SchemaV1.RoutineRun
typealias StepResult = SchemaV1.StepResult

/// Schema v1: the template graph here and the history graph in `SchemaV1+History.swift`
/// (docs/ARCHITECTURE.md → Схема v1).
///
/// Until the first release v1 may still change.
/// After a release it is frozen: changes go into `SchemaV2` and a stage in `AppMigrationPlan`.
enum SchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [DayPart.self, Routine.self, Step.self, Exercise.self, RoutineRun.self, StepResult.self]
    }

    /// A part of the day: «Утро», «Вечер». Its start time decides which part is current.
    @Model
    final class DayPart {
        var id: UUID
        var name: String
        /// SF Symbol.
        var symbol: String
        /// Minutes since midnight: 300 = 05:00.
        var startMinute: Int
        var sortIndex: Int
        @Relationship(deleteRule: .cascade, inverse: \Routine.dayPart)
        var routines: [Routine]

        init(id: UUID = UUID(), name: String, symbol: String, startMinute: Int, sortIndex: Int) {
            self.id = id
            self.name = name
            self.symbol = symbol
            self.startMinute = startMinute
            self.sortIndex = sortIndex
            routines = []
        }
    }

    /// A block inside a part of the day: «Зарядка», «Дневник». Scheduled by weekdays, made of steps.
    @Model
    final class Routine {
        var id: UUID
        var name: String
        /// SF Symbol.
        var symbol: String
        /// `RoutineTint` raw value from the design system.
        var colorName: String
        /// `Weekdays` raw value; use `weekdays`.
        var weekdaysRaw: Int
        var sortIndex: Int
        var isArchived: Bool
        var dayPart: DayPart?
        @Relationship(deleteRule: .cascade, inverse: \Step.routine)
        var steps: [Step]

        init(
            id: UUID = UUID(),
            name: String,
            symbol: String,
            colorName: String,
            weekdays: Weekdays = .everyDay,
            sortIndex: Int,
            isArchived: Bool = false
        ) {
            self.id = id
            self.name = name
            self.symbol = symbol
            self.colorName = colorName
            weekdaysRaw = weekdays.rawValue
            self.sortIndex = sortIndex
            self.isArchived = isArchived
            steps = []
        }

        var weekdays: Weekdays {
            // Masked: stray high bits from a damaged store are not days.
            get { Weekdays(rawValue: weekdaysRaw).intersection(.everyDay) }
            set { weekdaysRaw = newValue.rawValue }
        }
    }

    /// One building block of a routine. Its kind-specific settings live in `configData`.
    @Model
    final class Step {
        var id: UUID
        var sortIndex: Int
        /// `StepConfig.kind`, kept as a field for queries.
        var kindRaw: String
        /// JSON-encoded `StepConfig`; use `config`.
        var configData: Data
        /// Kept out of the config so charts and search can query by exercise.
        var exercise: Exercise?
        var routine: Routine?

        init(id: UUID = UUID(), sortIndex: Int, config: StepConfig, exercise: Exercise? = nil) throws {
            self.id = id
            self.sortIndex = sortIndex
            kindRaw = config.kind
            configData = try config.encoded()
            self.exercise = exercise
        }

        /// Decoded settings; `nil` if the stored data cannot be read.
        var config: StepConfig? {
            try? StepConfig(data: configData)
        }

        /// Replaces the settings and keeps `kindRaw` in sync.
        func setConfig(_ config: StepConfig) throws {
            configData = try config.encoded()
            kindRaw = config.kind
        }
    }

    /// An exercise in the library. Steps refer to it, so progress is tracked per exercise across routines.
    @Model
    final class Exercise {
        var id: UUID
        var name: String
        var notes: String
        /// Downscaled to about 1600 px.
        @Attribute(.externalStorage) var photo: Data?
        var isArchived: Bool
        /// Steps that use this exercise. The inverse is what makes deleting an exercise
        /// set `Step.exercise` to `nil` instead of leaving a reference to a deleted object.
        @Relationship(deleteRule: .nullify, inverse: \Step.exercise)
        var steps: [Step]
        /// History of this exercise, for charts. Nullified, not deleted: history outlives the library entry.
        @Relationship(deleteRule: .nullify, inverse: \StepResult.exercise)
        var results: [StepResult]

        init(id: UUID = UUID(), name: String, notes: String = "", photo: Data? = nil, isArchived: Bool = false) {
            self.id = id
            self.name = name
            self.notes = notes
            self.photo = photo
            self.isArchived = isArchived
            steps = []
            results = []
        }
    }
}

/// Migrations between schema versions. Empty while there is only v1.
enum AppMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [SchemaV1.self]
    }

    static var stages: [MigrationStage] {
        []
    }
}
