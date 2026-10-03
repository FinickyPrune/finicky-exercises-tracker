#!/bin/sh
# PreToolUse hook for `git commit` / `git push`: agents never work on main directly.
# main is also protected on GitHub; this just fails earlier and with a clearer message.
if [ "$(git branch --show-current 2>/dev/null)" = "main" ]; then
    echo "You are on main. Create a branch first: git switch -c feature/<code>-<slug>" >&2
    exit 2
fi
