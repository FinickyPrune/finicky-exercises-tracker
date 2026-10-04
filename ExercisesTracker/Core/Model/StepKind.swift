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

/// Settings of a step, whatever its kind. Stored JSON-encoded in `Step.configData`:
/// `{"type":"exercise","settings":{"sets":3,"target":{"reps":15}}}`.
///
/// The format is persisted, so it may only grow compatibly: a new field must be optional (or decode with a default),
/// fields are never renamed, a new kind is a new `type` value. Data with an unknown `type` fails to decode,
/// and `Step.config` returns `nil` for it.
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

// MARK: - Persisted format

// Explicit coding instead of the synthesized `{"exercise":{"_0":…}}` shape, which is hard to read and to evolve.

nonisolated extension StepConfig {
    private enum CodingKeys: String, CodingKey {
        case type
        case settings
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case ExerciseStep.kind: self = try .exercise(container.decode(ExerciseStep.self, forKey: .settings))
        case LinkStep.kind: self = try .link(container.decode(LinkStep.self, forKey: .settings))
        case CheckStep.kind: self = try .check(container.decode(CheckStep.self, forKey: .settings))
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .type, in: container, debugDescription: "Unknown step kind \(type)"
            )
        }
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(kind, forKey: .type)
        switch self {
        case let .exercise(step): try container.encode(step, forKey: .settings)
        case let .link(step): try container.encode(step, forKey: .settings)
        case let .check(step): try container.encode(step, forKey: .settings)
        }
    }
}

/// `{"reps":15}` or `{"seconds":30}`.
nonisolated extension ExerciseStep.Target {
    private enum CodingKeys: String, CodingKey {
        case reps
        case seconds
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let reps = try container.decodeIfPresent(Int.self, forKey: .reps) {
            self = .reps(reps)
        } else if let seconds = try container.decodeIfPresent(Int.self, forKey: .seconds) {
            self = .duration(seconds: seconds)
        } else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: decoder.codingPath, debugDescription: "Target has neither reps nor seconds")
            )
        }
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .reps(count): try container.encode(count, forKey: .reps)
        case let .duration(seconds): try container.encode(seconds, forKey: .seconds)
        }
    }
}
