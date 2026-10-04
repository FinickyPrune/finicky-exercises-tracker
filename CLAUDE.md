# Exercises Tracker

Native iOS app (pet project): a tracker for daily routines, starting with morning exercises.

- Product, glossary, roadmap: [docs/PRODUCT.md](docs/PRODUCT.md)
- Data model and architecture decisions: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)
- Visual direction, tokens, components, haptics: [docs/DESIGN.md](docs/DESIGN.md)

Read PRODUCT and ARCHITECTURE before working on a feature, and DESIGN before any UI work. Feature/subtask numbers (e.g. 3.2) come from PRODUCT.md.

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
| `make check` | lint + test — the dev loop |
| `make format` | SwiftFormat in place — only before a PR. Pinned version (Makefile), downloaded to `.build/tools/` on first use |

Test results: `.build/DerivedData/Logs/Test/*.xcresult`, readable with `xcrun xcresulttool get test-results summary --path <file>`.

## Rules

- **The Xcode project is generated.** Never edit `*.xcodeproj` — change `project.yml` and run `make gen`. New source files are picked up automatically by folder.
- **Before saying a task is done, run `make check`** and report the result. If it fails, fix it or say what is failing.
- New logic comes with tests in `ExercisesTrackerTests/`, mirroring the source folder structure.
- For UI changes, launch the app in the simulator and check the screen, not just the build.
- **UI goes through the design system** (`Core/DesignSystem/`). No color, font, spacing or radius literals and no direct haptic calls in `Features/`. A new component goes into the design system with a `#Preview` and into the gallery.
- **SwiftFormat runs only before a PR**, not during development. Don't run `make format` mid-task. Before `gh pr create`: `make format`, commit, push. A hook blocks `gh pr create` while files are unformatted, and CI checks formatting too.
- Work on a branch, never commit to `main` directly. Branch names: `feature/…`, `fix/…`, `chore/…`. `main` is protected on GitHub (PR with a green `check` job, squash merge only), and a hook blocks `git commit`/`git push` while on `main`.
- Commit messages: imperative mood, short subject line (`Add workout list screen`).

## Architecture

```
ExercisesTracker/
  App/          entry point, root navigation
  Core/         Model, Persistence, Scheduling, DesignSystem
  Features/     Today, RoutineRun, Editor, Library — views and view models
  Resources/    assets
ExercisesTrackerTests/
```

- State: `@Observable` models; views own them with `@State`, pass them down as plain properties or via `@Environment`.
- Keep views thin: logic that can be unit-tested lives in models, not in `body`.
- Persistence: SwiftData, behind the `RoutineStore` protocol. Template and history are separate graphs — see docs/ARCHITECTURE.md.

## Workflow with agents

Work is tracked as GitHub issues: one epic per feature (`F3 · …`) with sub-issues per subtask (`[3.2] …`), grouped into milestones. Each subtask issue lists its dependencies and acceptance criteria.

1. Read the issue: `gh issue view <N>`. Its dependencies must already be merged.
2. Branch `feature/<code>-<slug>`, e.g. `feature/3.2-quick-confirm`.
3. Implement; `make check` passes; every acceptance criterion is met or explicitly called out.
4. Run the `ios-reviewer` subagent on the branch; fix blockers. Use `test-writer` if coverage is missing.
5. `make format`, commit the formatting as its own commit, push.
6. Open a PR with `gh pr create`, `Closes #<N>` in the body; CI must be green before merge.
