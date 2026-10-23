#!/usr/bin/env bash
# PostToolUse hook (matcher: Bash). After a successful `git commit`, remind Claude
# to report the commit and pause for review before continuing.
set -euo pipefail

command -v jq >/dev/null 2>&1 || exit 0

cmd=$(jq -r '.tool_input.command // empty')

case "$cmd" in
  *"git commit"*) ;;
  *) exit 0 ;;
esac

msg="A commit was just made. Per global CLAUDE.md: report it now (hash, message, diffstat via \`git show --stat --format=fuller HEAD\`), then STOP and wait for the user to approve or acknowledge review. Do not start the next piece of work or make another commit until they respond."

jq -n --arg msg "$msg" '{hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: $msg}}'
