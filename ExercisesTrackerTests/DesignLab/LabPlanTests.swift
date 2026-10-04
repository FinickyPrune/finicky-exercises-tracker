#if DEBUG
    @testable import ExercisesTracker
    import Testing

    struct LabPlanTests {
        @Test func repsShowCountAndUnit() {
            let plan = LabExercise.Plan.reps(sets: 3, reps: 15)
            #expect(plan.sets == 3)
            #expect(plan.value == "15")
            #expect(plan.unit == " повт")
            #expect(!plan.isTimed)
        }

        @Test(arguments: [(30, "0:30"), (90, "1:30"), (5, "0:05"), (600, "10:00")])
        func timeIsMinutesAndPaddedSeconds(seconds: Int, expected: String) {
            let plan = LabExercise.Plan.time(sets: 1, seconds: seconds)
            #expect(plan.value == expected)
            #expect(plan.unit.isEmpty)
            #expect(plan.isTimed)
        }
    }
#endif
