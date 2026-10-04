import Foundation

/// What was actually done in a step, whatever its kind. Stored JSON-encoded in `StepResult.actualData`:
/// `{"type":"exercise","value":[{"reps":15},{"reps":12}]}`, `{"type":"check","value":true}`.
///
/// Same evolution rules as `StepConfig`: the format only grows compatibly.
nonisolated enum StepActual: Codable, Hashable, Sendable {
    case exercise(ExerciseStep.Result)
    case link(LinkStep.Result)
    case check(CheckStep.Result)

    /// The «по плану» result for a step with these settings.
    init(asPlannedFor config: StepConfig) {
        switch config {
        case let .exercise(step): self = .exercise(step.resultAsPlanned())
        case let .link(step): self = .link(step.resultAsPlanned())
        case let .check(step): self = .check(step.resultAsPlanned())
        }
    }

    var kind: String {
        switch self {
        case .exercise: ExerciseStep.kind
        case .link: LinkStep.kind
        case .check: CheckStep.kind
        }
    }

    /// Whether this result completes a step with `config`. A result of another kind never does.
    func completes(_ config: StepConfig) -> Bool {
        switch (config, self) {
        case let (.exercise(step), .exercise(result)): step.isComplete(result)
        case let (.link(step), .link(result)): step.isComplete(result)
        case let (.check(step), .check(result)): step.isComplete(result)
        default: false
        }
    }

    func encoded() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        return try encoder.encode(self)
    }

    init(data: Data) throws {
        self = try JSONDecoder().decode(StepActual.self, from: data)
    }
}

// MARK: - Persisted format

nonisolated extension StepActual {
    private enum CodingKeys: String, CodingKey {
        case type
        case value
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case ExerciseStep.kind: self = try .exercise(container.decode(ExerciseStep.Result.self, forKey: .value))
        case LinkStep.kind: self = try .link(container.decode(LinkStep.Result.self, forKey: .value))
        case CheckStep.kind: self = try .check(container.decode(CheckStep.Result.self, forKey: .value))
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
        case let .exercise(result): try container.encode(result, forKey: .value)
        case let .link(result): try container.encode(result, forKey: .value)
        case let .check(result): try container.encode(result, forKey: .value)
        }
    }
}
