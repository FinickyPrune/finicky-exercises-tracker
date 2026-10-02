#!/bin/sh
# PostToolUse hook: format the Swift file Claude just wrote or edited.
# Never fails the tool call: a half-written file that SwiftFormat can't parse is left as is.
file=$(jq -r '.tool_input.file_path // empty')
case "$file" in
    *.swift) swiftformat --quiet --config "$CLAUDE_PROJECT_DIR/.swiftformat" "$file" 2>/dev/null ;;
esac
exit 0
