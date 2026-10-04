import Foundation
@testable import ExercisesTracker
import Testing

struct StepConfigTests {
    nonisolated private static let configs: [StepConfig] = [
        .exercise(ExerciseStep(sets: 3, target: .reps(15), restSeconds: nil)),
        .exercise(ExerciseStep(sets: 3, target: .duration(seconds: 30), restSeconds: 20)),
        .link(LinkStep(title: "Урок", url: testURL("duolingo://"))),
        .check(CheckStep(title: "Витамины")),
    ]

    @Test(arguments: configs)
    func roundTripsThroughData(config: StepConfig) throws {
        let data = try config.encoded()
        #expect(try StepConfig(data: data) == config)
    }

    @Test(arguments: zip(configs, ["exercise", "exercise", "link", "check"]))
    func kindMatchesStepKind(config: StepConfig, kind: String) {
        #expect(config.kind == kind)
    }

    @Test func encodingIsStable() throws {
        let config = StepConfig.check(CheckStep(title: "Витамины"))
        #expect(try config.encoded() == config.encoded())
    }

    @Test func garbageDataDoesNotDecode() {
        #expect(throws: (any Error).self) { try StepConfig(data: Data("not json".utf8)) }
    }

    @Test func exerciseAsPlannedFillsEverySet() {
        let step = ExerciseStep(sets: 3, target: .reps(15), restSeconds: nil)
        let result = step.resultAsPlanned()
        #expect(result == [.reps(15), .reps(15), .reps(15)])
        #expect(step.isComplete(result))
    }

    @Test func exerciseWithFewerRepsIsStillComplete() {
        let step = ExerciseStep(sets: 3, target: .reps(10), restSeconds: nil)
        #expect(step.isComplete([.reps(10), .reps(8), .reps(8)]))
    }

    @Test func exerciseWithMissingSetsIsIncomplete() {
        let step = ExerciseStep(sets: 3, target: .duration(seconds: 30), restSeconds: nil)
        #expect(!step.isComplete([.duration(seconds: 30)]))
    }

    @Test func checkAndLinkAreCompleteWhenTrue() {
        let check = CheckStep(title: "Витамины")
        #expect(check.isComplete(check.resultAsPlanned()))
        #expect(!check.isComplete(false))
        let link = LinkStep(title: "Урок", url: testURL("duolingo://"))
        #expect(link.isComplete(link.resultAsPlanned()))
    }
}
