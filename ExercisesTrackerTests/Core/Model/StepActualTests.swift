@testable import ExercisesTracker
import Foundation
import Testing

struct StepActualTests {
    private let squats = StepConfig.exercise(ExerciseStep(sets: 3, target: .reps(15)))
    private let plank = StepConfig.exercise(ExerciseStep(sets: 2, target: .duration(seconds: 30)))
    private let lesson = StepConfig.link(LinkStep(title: "Урок", url: testURL("duolingo://")))
    private let vitamins = StepConfig.check(CheckStep(title: "Витамины"))

    @Test func asPlannedForExerciseFillsEverySet() {
        #expect(StepActual(asPlannedFor: squats) == .exercise([.reps(15), .reps(15), .reps(15)]))
        #expect(StepActual(asPlannedFor: plank) == .exercise([.duration(seconds: 30), .duration(seconds: 30)]))
    }

    @Test func asPlannedForLinkAndCheckIsTrue() {
        #expect(StepActual(asPlannedFor: lesson) == .link(true))
        #expect(StepActual(asPlannedFor: vitamins) == .check(true))
    }

    @Test func asPlannedCompletesEveryKind() {
        for config in [squats, plank, lesson, vitamins] {
            #expect(StepActual(asPlannedFor: config).completes(config))
        }
    }

    @Test func fewerRepsStillComplete() {
        #expect(StepActual.exercise([.reps(15), .reps(12), .reps(10)]).completes(squats))
    }

    @Test func missingSetsDoNotComplete() {
        #expect(!StepActual.exercise([.reps(15)]).completes(squats))
    }

    @Test func falseDoesNotComplete() {
        #expect(!StepActual.link(false).completes(lesson))
        #expect(!StepActual.check(false).completes(vitamins))
    }

    @Test func otherKindNeverCompletes() {
        #expect(!StepActual.check(true).completes(lesson))
        #expect(!StepActual.exercise([.reps(15)]).completes(vitamins))
    }

    @Test(arguments: [
        (StepActual.exercise([.reps(15), .reps(12)]), #"{"type":"exercise","value":[{"reps":15},{"reps":12}]}"#),
        (.exercise([.duration(seconds: 30)]), #"{"type":"exercise","value":[{"seconds":30}]}"#),
        (.link(true), #"{"type":"link","value":true}"#),
        (.check(false), #"{"type":"check","value":false}"#),
    ])
    func encodesToPinnedJSONAndBack(actual: StepActual, json: String) throws {
        #expect(try String(bytes: actual.encoded(), encoding: .utf8) == json)
        #expect(try StepActual(data: Data(json.utf8)) == actual)
    }
}
