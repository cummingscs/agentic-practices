#!/usr/bin/env bash
# SessionStart hook: surface .claude/PLAN.md (open TODOs and Considerations) as session context.
# Prints nothing when the project has no PLAN.md.
set -euo pipefail

root="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
plan="$root/.claude/PLAN.md"
[ -f "$plan" ] || exit 0

next=$(awk '/^## /{s=($0 ~ /^## Next/)} s && /^- \[ \]/{c++} END{print c+0}' "$plan")
titles=$(awk '/^## /{s=($0 ~ /^## Considerations/)} s && /^### /{sub(/^### /,""); printf "%s%s", sep, $0; sep="; "}' "$plan")

msg="$plan has $next open TODO(s) under Next."
[ -n "$titles" ] && msg="$msg Considerations queued: $titles."
msg="$msg Considerations are flagged to the user at checkpoints when their value matches a present problem."
printf '%s\n' "$msg"
