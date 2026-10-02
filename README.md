# finicky-exercises-tracker

Native iOS app for tracking exercises. Pet project.

## Setup

Requires Xcode 26+ and Homebrew.

```sh
make bootstrap   # installs xcodegen, swiftlint, swiftformat
make open        # generates ExercisesTracker.xcodeproj and opens it
```

The Xcode project is generated from `project.yml` and is not committed.

## Everyday commands

```sh
make test     # unit tests on the simulator
make lint     # SwiftLint
make check    # lint + tests
make format   # SwiftFormat — run before opening a PR
```

## Working with Claude Code

- `CLAUDE.md` — project context and rules every Claude session reads.
- `.claude/settings.json` — allowed commands and a hook that blocks `gh pr create` until SwiftFormat has been run.
- `.claude/agents/` — subagents: `ios-reviewer` (read-only review of the branch) and `test-writer`.
