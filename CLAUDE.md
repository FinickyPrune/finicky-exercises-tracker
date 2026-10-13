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
| `make sync` | After a PR is merged on GitHub: switch to `main`, pull, delete local branches whose remote is gone |

Test results: `.build/DerivedData/Logs/Test/*.xcresult`, readable with `xcrun xcresulttool get test-results summary --path <file>`.

## Rules

- **The Xcode project is generated.** Never edit `*.xcodeproj` — change `project.yml` and run `make gen`. New source files are picked up automatically by folder.
- **Before saying a task is done, run `make check`** and report the result. If it fails, fix it or say what is failing.
- New logic comes with tests in `ExercisesTrackerTests/` (or `DesignSystemTests/` for the `DesignSystem` target), mirroring the source folder structure.
- For UI changes, launch the app in the simulator and check the screen, not just the build.
- **UI goes through the design system** (the `DesignSystem` framework target, introduced in 0.2 — see docs/ARCHITECTURE.md). No color, font, spacing or radius literals and no direct haptic calls in `Features/`. A new component goes into the design system with a `#Preview` and into the gallery.
- **SwiftFormat runs only before a PR**, not during development. Don't run `make format` mid-task. Before `gh pr create`: `make format`, commit, push. A hook blocks `gh pr create` while files are unformatted, and CI checks formatting too.
- Work on a branch, never commit to `main` directly. Branch names: `feature/…`, `fix/…`, `chore/…`. `main` is protected on GitHub (PR with a green `check` job, squash merge only), and a hook blocks `git commit`/`git push` while on `main`.
- Commit messages: imperative mood, short subject line (`Add workout list screen`).
- PR descriptions are short: `Closes #<N>`, a few one-line bullets on what changed, the acceptance-criteria checklist. No "Проверка" section when `make check` and the review are clean — only mention checks when something failed, was skipped or is worth flagging. No attribution footer.

## Architecture

```
ExercisesTracker/
  App/          entry point, root navigation
  Core/         Model, Persistence, Scheduling
  Features/     Today, RoutineRun, Editor, Library — views and view models
  Resources/    assets, Localizable.xcstrings
  Debug/        design-system gallery, Debug builds only
ExercisesTrackerTests/
DesignSystem/   framework target: tokens, components, feedback, its own Localizable.xcstrings
DesignSystemTests/
TestSupport/    helpers compiled into both test targets
```

- State: `@Observable` models; views own them with `@State`, pass them down as plain properties or via `@Environment`.
- Keep views thin: logic that can be unit-tested lives in models, not in `body`.
- Persistence: SwiftData, behind the `RoutineStore` protocol. Template and history are separate graphs — see docs/ARCHITECTURE.md.

## Localization

English is the base language, Russian the second one. All user-facing text is localized, including the gallery, previews and demo data.

- Text lives in the String Catalog of the target whose code shows it: `ExercisesTracker/Resources/Localizable.xcstrings` or `DesignSystem/Resources/Localizable.xcstrings`. Text the app passes into a design-system component belongs to the app's catalog: generated symbols are `internal` to their target.
- A key is camelCase and prefixed by its area (`today…`, `demo…`, `gallery…`, `preview…`). Add it by hand in alphabetical order (Xcode re-sorts on save), with an English and a Russian value and a comment that explains every placeholder:

  ```json
  "todayEmptyTitle" : {
    "comment" : "Placeholder of the Today screen.",
    "extractionState" : "manual",
    "localizations" : {
      "en" : { "stringUnit" : { "state" : "translated", "value" : "Nothing here yet" } },
      "ru" : { "stringUnit" : { "state" : "translated", "value" : "Пока пусто" } }
    }
  }
  ```
- Placeholders: `%lld` becomes an `Int` argument of the symbol, `%@` a `String`; with more than one, number them (`%1$lld из %2$lld`) so a translation may reorder them. Format times, dates and measurements with the view's locale and pass them as `%@`.
- Plurals: put `"variations" : { "plural" : { … } }` in place of `stringUnit`, with `one` and `other` in English and `one`, `few`, `many`, `other` in Russian.
- Code uses the generated symbols: `Text(.todayTitle)`, `.galleryProgress(2, 6)`, `String(localized: .historyExerciseFallback)` outside views. Data from the store is shown as it is: `Text(routine.name)`.
- `LocalizedStringResource` silently accepts a string literal, so `status: "Done"` compiles and is never translated. Always pass a symbol.
- Design-system components take `LocalizedStringResource` for interface text and `String` for data. Text a function composes, such as a VoiceOver label, takes a `locale` from `@Environment(\.locale)`, so tests can check both languages.
- Literals stay only for `#Preview` names (in English), SF Symbol names and identifiers. Gallery and preview samples use the device language: switch it to check the other one.
- Checks:
  - SwiftLint rejects Cyrillic in string literals, a text literal as the first argument of `Text`, `Label`, `Button` and the like, and a literal in `status:`, `subtitle:`, `prompt:`, `message:`, `hint:` or `placeholder:`. A new component that takes text first goes into the `text_literal` list in `.swiftlint.yml`.
  - A literal inside a ternary (`flag ? "A" : "B"`) is not caught: SF Symbol names take the same shape.
  - `LocalizationTests` fails on a key without a translation, a comment or a plural form, or with placeholders that differ between languages.
- A new language goes into both catalogs and into `StringCatalogCheck.languages` and `pluralCategories`. Info.plist text (usage descriptions, the display name) would need an `InfoPlist.xcstrings`; there is none yet.

## SwiftUI Pro skill

`.claude/skills/swiftui-pro/` is Paul Hudson's SwiftUI review skill, vendored at a pinned commit (see its `UPSTREAM.md`; its files stay unchanged). `/swiftui-pro [focus]` runs it, and `ios-reviewer` checks UI changes against it. Where it disagrees with this project, the project wins:

- Colors, fonts, spacing and radii come from `DesignSystem` tokens, haptics from its feedback catalog — not system styles or literals. Its typography already follows Dynamic Type.
- Small related types may share a file: a type with its enum, private helpers, an `extension`. Small private `some View` helpers in a view are fine too.
- The deployment target is iOS 26: iOS 27+ APIs only behind `#available`.
- iPhone only, portrait: iPad, window resizing and iPhone Duo layouts are out of scope for now.
- Localization follows «Localization» above. That matches the skill's String Catalog rules; generated symbols already carry their bundle, so no `bundle:` arguments.

## Workflow with agents

Work is tracked as GitHub issues: one epic per feature (`F3 · …`) with sub-issues per subtask (`[3.2] …`), grouped into milestones. Each subtask issue lists its dependencies and acceptance criteria.

1. Read the issue: `gh issue view <N>`. Its dependencies must already be merged.
2. Branch `feature/<code>-<slug>`, e.g. `feature/3.2-quick-confirm`.
3. Implement; `make check` passes; every acceptance criterion is met or explicitly called out.
4. Run the `ios-reviewer` subagent on the branch; fix blockers. For UI changes it also applies the `swiftui-pro` skill. Use `test-writer` if coverage is missing.
5. `make format`, commit the formatting as its own commit, push.
6. Open a PR with `gh pr create`, `Closes #<N>` in the body; CI must be green before merge.
7. Merge with `gh pr merge --squash --delete-branch`: it deletes the branch on GitHub and locally and leaves you on an up-to-date `main`. GitHub also deletes merged branches on its side; after a merge in the web UI, run `make sync`.
