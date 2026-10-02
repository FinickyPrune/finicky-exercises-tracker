# Exercises Tracker

Native iOS app (pet project). The product scope is not defined yet — see "Architecture" below for what is decided.

## Stack

- iOS 26+, iPhone only, portrait
- SwiftUI, Swift 6 language mode, default actor isolation = `MainActor`
- Swift Testing for unit tests
- No third-party dependencies. Ask before adding one.
- Bundle ID: `com.finickyprune.exercisestracker`

## Commands

Always go through the Makefile — CI runs the same targets.

| Command | What it does |
|---|---|
| `make gen` | Regenerate `ExercisesTracker.xcodeproj` from `project.yml` |
| `make build` | Build for the simulator |
| `make test` | Run unit tests on the simulator (`SIMULATOR="..."` to override) |
| `make lint` | SwiftLint, strict |
| `make format` | SwiftFormat in place |
| `make check` | format-check + lint + test — what CI runs |

Test results: `.build/DerivedData/Logs/Test/*.xcresult`, readable with `xcrun xcresulttool get test-results summary --path <file>`.

## Rules

- **The Xcode project is generated.** Never edit `*.xcodeproj` — change `project.yml` and run `make gen`. New source files are picked up automatically by folder.
- **Before saying a task is done, run `make check`** and report the result. If it fails, fix it or say what is failing.
- New logic comes with tests in `ExercisesTrackerTests/`, mirroring the source folder structure.
- For UI changes, launch the app in the simulator and check the screen, not just the build.
- Formatting is automatic (a hook runs SwiftFormat after every edit). Don't fight it.
- Work on a branch, never commit to `main` directly. Branch names: `feature/…`, `fix/…`, `chore/…`.
- Commit messages: imperative mood, short subject line (`Add workout list screen`).

## Architecture

```
ExercisesTracker/
  App/          entry point, root navigation
  Features/     one folder per feature: Views, view models, feature-local models
  Core/         shared models, persistence, utilities
  Resources/    assets
ExercisesTrackerTests/
```

- State: `@Observable` models; views own them with `@State`, pass them down as plain properties or via `@Environment`.
- Keep views thin: logic that can be unit-tested lives in models, not in `body`.
- Persistence: not chosen yet (SwiftData is the default candidate).

## Workflow with agents

1. Implement on a feature branch.
2. `make check` passes.
3. Run the `ios-reviewer` subagent on the branch; fix blockers. Use `test-writer` if coverage is missing.
4. Open a PR with `gh pr create`; CI must be green before merge.
