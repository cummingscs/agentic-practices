#!/usr/bin/env bash
# PostToolUse hook (matcher: Bash). When HEAD's reflog gained a commit-creating
# entry since this hook last ran in the repo, remind Claude to report the commit
# and pause for review before continuing. It reads the reflog, not the command
# text, so mentions of "git commit", dry runs, failed commits and pulls stay silent.
set -euo pipefail

command -v jq >/dev/null 2>&1 || exit 0

cwd=$(jq -r '.cwd // empty')
[ -n "$cwd" ] && cd "$cwd" 2>/dev/null || exit 0
git rev-parse --git-dir >/dev/null 2>&1 || exit 0

log=$(git rev-parse --git-path logs/HEAD)
state=$(git rev-parse --git-path claude-commit-checkpoint)
[ -s "$log" ] || exit 0

# Read the log once, and scan and record from this snapshot only. Anything
# appended later is picked up on the next run, so a commit is never skipped.
snapshot=$(cat "$log")
newest=${snapshot##*$'\n'}
marker=$(cat "$state" 2>/dev/null || true)

# Entries after the last line we recorded are new. If the marker is missing or
# no longer in the log (corrupt state, expired reflog), set a baseline silently.
fired=0
if [ -n "$marker" ] && new=$(printf '%s\n' "$snapshot" | M="$marker" awk '
    $0 == ENVIRON["M"] { seen = 1; out = ""; next }
    seen { out = out $0 "\n" }
    END { printf "%s", out; exit !seen }'); then
  # Actions follow the tab; pulls ("pull: ...", "pull --rebase ...") never match.
  if printf '%s' "$new" | cut -f2- |
    grep -qE '^(commit|rebase( -i)? \(finish\)|merge .*: Merge made|cherry-pick|revert)'; then
    fired=1
  fi
fi

# Record only what this run scanned; write then rename so a reader never sees a
# half-written file. A stale overwrite from a parallel run only causes a rescan.
tmp=$(mktemp "$state.XXXXXX")
printf '%s\n' "$newest" >"$tmp"
mv -f "$tmp" "$state"

[ "$fired" -eq 1 ] || exit 0

msg="A commit was just made. Per global CLAUDE.md: report it now (hash, message, diffstat via \`git show --stat --format=fuller HEAD\`), then STOP and wait for the user to approve or acknowledge review. Do not start the next piece of work or make another commit until they respond."

jq -n --arg msg "$msg" '{hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: $msg}}'
