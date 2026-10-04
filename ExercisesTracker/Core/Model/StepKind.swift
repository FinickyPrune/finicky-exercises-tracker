import Foundation

/// Behavior of one kind of step. A new kind is a type conforming to this protocol plus a case in `StepConfig`.
nonisolated protocol StepKind: Codable, Hashable, Sendable {
    /// What was actually done.
    associatedtype Result: Codable, Hashable, Sendable

    /// Value of `Step.kindRaw` and `StepResult.kindRaw`.
    static var kind: String { get }

    /// The result of «сделано по плану» — one tap.
    func resultAsPlanned() -> Result

    func isComplete(_ result: Result) -> Bool
}

/// An exercise from the library, done for a number of sets.
nonisolated struct ExerciseStep: StepKind {
    /// What one set is: a number of reps or a duration.
    enum Target: Codable, Hashable, Sendable {
        case reps(Int)
        case duration(seconds: Int)
    }

    var sets: Int
    var target: Target
    var restSeconds: Int?

    /// The fact for each set, in the same units as the target. Fewer reps than planned still counts as done.
    typealias Result = [Target]

    static let kind = "exercise"

    func resultAsPlanned() -> [Target] {
        Array(repeating: target, count: sets)
    }

    /// Done when every set has a recorded fact.
    func isComplete(_ result: [Target]) -> Bool {
        result.count >= sets
    }
}

/// Opens another app or a URL, then is checked off in the list: Duolingo, Journal.
nonisolated struct LinkStep: StepKind {
    var title: String
    var url: URL

    typealias Result = Bool

    static let kind = "link"

    func resultAsPlanned() -> Bool {
        true
    }

    func isComplete(_ result: Bool) -> Bool {
        result
    }
}

/// A plain checkbox: «Витамины».
nonisolated struct CheckStep: StepKind {
    var title: String

    typealias Result = Bool

    static let kind = "check"

    func resultAsPlanned() -> Bool {
        true
    }

    func isComplete(_ result: Bool) -> Bool {
        result
    }
}

/// Settings of a step, whatever its kind. Stored JSON-encoded in `Step.configData`.
nonisolated enum StepConfig: Codable, Hashable, Sendable {
    case exercise(ExerciseStep)
    case link(LinkStep)
    case check(CheckStep)

    /// Value of `Step.kindRaw`.
    var kind: String {
        switch self {
        case .exercise: ExerciseStep.kind
        case .link: LinkStep.kind
        case .check: CheckStep.kind
        }
    }

    func encoded() throws -> Data {
        try Self.encoder.encode(self)
    }

    init(data: Data) throws {
        self = try JSONDecoder().decode(StepConfig.self, from: data)
    }

    private static var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        return encoder
    }
}
