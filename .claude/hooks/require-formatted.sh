#!/bin/sh
# PreToolUse hook for `gh pr create`: block the PR until SwiftFormat has been run and committed.
# Goes through make so it uses the same pinned SwiftFormat as CI.
cd "$CLAUDE_PROJECT_DIR" || exit 0
if ! make -s format-check >/dev/null 2>&1; then
    echo "SwiftFormat: some files are not formatted. Run \`make format\`, commit the changes, push, then open the PR." >&2
    exit 2
fi
