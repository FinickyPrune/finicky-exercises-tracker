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
make format   # SwiftFormat
make check    # everything CI runs
```

## Working with Claude Code

- `CLAUDE.md` — project context and rules every Claude session reads.
- `.claude/settings.json` — allowed commands and a hook that formats Swift files after every edit.
- `.claude/agents/` — subagents: `ios-reviewer` (read-only review of the branch) and `test-writer`.
