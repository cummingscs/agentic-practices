#!/usr/bin/env bash
# Tests for claude/hooks/commit-checkpoint.sh. Each case builds a throwaway repo,
# performs a git action directly, then feeds the hook a PostToolUse payload and
# checks whether it printed the commit reminder.
# Run: bash tests/hooks/commit-checkpoint.test.sh
set -uo pipefail

root=$(cd "$(dirname "$0")/../.." && pwd)
hook=${HOOK:-$root/claude/hooks/commit-checkpoint.sh}

# Isolate from the user's git config, commit template and hooks.
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
export GIT_AUTHOR_NAME=Test GIT_AUTHOR_EMAIL=test@example.com
export GIT_COMMITTER_NAME=Test GIT_COMMITTER_EMAIL=test@example.com

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
pass=0 fail=0

# run_hook <dir> <command text>: prints "fired" or "silent".
run_hook() {
  local out
  out=$(jq -n --arg cwd "$1" --arg cmd "$2" \
    '{cwd: $cwd, tool_name: "Bash", tool_input: {command: $cmd}}' | bash "$hook")
  case "$out" in *"A commit was just made"*) echo fired ;; *) echo silent ;; esac
}

# expect <name> <fired|silent> <actual>
expect() {
  if [ "$2" = "$3" ]; then
    pass=$((pass + 1)); echo "ok   $1"
  else
    fail=$((fail + 1)); echo "FAIL $1: expected $2, got $3"
  fi
}

# mk <dir> <file> <message>: commit a change to <file>.
mk() {
  echo "$3" >>"$1/$2"
  git -C "$1" add "$2"
  git -C "$1" commit -q -m "$3"
}

prime() { run_hook "$1" "git status" >/dev/null; }

# new_repo <name>: a repo with one commit and a hook baseline.
new_repo() {
  local d="$work/$1"
  git init -q -b main "$d"
  mk "$d" init.txt init
  prime "$d"
  echo "$d"
}

# new_clone <name>: an upstream repo and a primed clone of it; prints the clone.
new_clone() {
  local up="$work/$1-up" d="$work/$1"
  git init -q -b main "$up"
  mk "$up" init.txt init
  git clone -q "$up" "$d"
  prime "$d"
  echo "$d"
}

state() { echo "$1/.git/claude-commit-checkpoint"; }

echo "# Fires"

d=$(new_repo commit)
mk "$d" a.txt one
expect "real commit fires" fired "$(run_hook "$d" "git commit -m one")"
expect "next run after a fired commit is silent" silent "$(run_hook "$d" "git status")"

d=$(new_repo amend)
git -C "$d" commit -q --amend -m init2
expect "amend fires" fired "$(run_hook "$d" "git commit --amend -m init2")"

d=$(new_repo rebase)
git -C "$d" checkout -q -b feature && mk "$d" f.txt feature
git -C "$d" checkout -q main && mk "$d" m.txt main
git -C "$d" checkout -q feature && prime "$d"
git -C "$d" rebase -q main
expect "finished rebase fires" fired "$(run_hook "$d" "git rebase main")"

d=$(new_repo merge)
git -C "$d" checkout -q -b feature && mk "$d" f.txt feature
git -C "$d" checkout -q main && mk "$d" m.txt main && prime "$d"
git -C "$d" merge -q --no-ff --no-edit feature
expect "merge commit fires" fired "$(run_hook "$d" "git merge --no-ff feature")"

d=$(new_repo cherry-pick)
git -C "$d" checkout -q -b feature && mk "$d" f.txt feature
git -C "$d" checkout -q main && prime "$d"
git -C "$d" cherry-pick feature >/dev/null
expect "cherry-pick fires" fired "$(run_hook "$d" "git cherry-pick feature")"

d=$(new_repo revert)
mk "$d" r.txt change && prime "$d"
git -C "$d" revert --no-edit HEAD >/dev/null
expect "revert fires" fired "$(run_hook "$d" "git revert HEAD")"

d=$(new_clone pull-after-commit)
mk "$work/pull-after-commit-up" up.txt upstream
mk "$d" local.txt local
git -C "$d" pull -q --no-rebase --no-edit
expect "commit followed by a pull fires" fired "$(run_hook "$d" "git pull")"

d="$work/expire"
git init -q -b main "$d"
GIT_COMMITTER_DATE="2020-01-01T00:00:00" mk "$d" old.txt old1
GIT_COMMITTER_DATE="2020-01-02T00:00:00" mk "$d" old.txt old2
mk "$d" recent.txt recent && prime "$d"
before=$(wc -l <"$d/.git/logs/HEAD")
git -C "$d" reflog expire --expire=2021-01-01 --all
after=$(wc -l <"$d/.git/logs/HEAD")
[ "$after" -lt "$before" ] || echo "SETUP expire did not shrink the reflog ($before -> $after)"
mk "$d" new.txt new
expect "commit after reflog expiry fires" fired "$(run_hook "$d" "git commit -m new")"

d=$(new_repo stale)
cp "$(state "$d")" "$work/stale-saved" 2>/dev/null || : >"$work/stale-saved"
mk "$d" s.txt stale
expect "commit fires before a stale overwrite" fired "$(run_hook "$d" "git commit -m stale")"
cp "$work/stale-saved" "$(state "$d")"
expect "stale state re-fires (duplicate, not a miss)" fired "$(run_hook "$d" "git status")"
expect "then silent" silent "$(run_hook "$d" "git status")"

echo "# Silent"

d=$(new_repo echo)
expect "echo mentioning git commit" silent "$(run_hook "$d" "echo 'git commit'")"

d=$(new_repo dry-run)
echo x >"$d/x.txt" && git -C "$d" add x.txt
git -C "$d" commit --dry-run -m x >/dev/null
expect "git commit --dry-run" silent "$(run_hook "$d" "git commit --dry-run -m x")"

d=$(new_repo failed)
git -C "$d" commit -q -m nothing >/dev/null 2>&1
expect "failed commit (nothing to commit)" silent "$(run_hook "$d" "git commit -m nothing")"

d=$(new_repo heredoc)
expect "heredoc mentioning git commit" silent \
  "$(run_hook "$d" "$(printf 'cat <<EOF\nthen run git commit -m x\nEOF')")"

d=$(new_repo checkout)
git -C "$d" checkout -q -b other
expect "branch checkout" silent "$(run_hook "$d" "git checkout -b other")"

d=$(new_clone ff-pull)
mk "$work/ff-pull-up" up.txt upstream
git -C "$d" pull -q
expect "fast-forward pull" silent "$(run_hook "$d" "git pull")"

d=$(new_clone merge-pull)
mk "$work/merge-pull-up" up.txt upstream
mk "$d" local.txt local && prime "$d"
git -C "$d" pull -q --no-rebase --no-edit
expect "pull that creates a merge commit" silent "$(run_hook "$d" "git pull --no-rebase")"

d=$(new_clone rebase-pull)
mk "$work/rebase-pull-up" up.txt upstream
mk "$d" local.txt local && prime "$d"
git -C "$d" pull -q --rebase
expect "pull --rebase" silent "$(run_hook "$d" "git pull --rebase")"

d="$work/first-run"
git init -q -b main "$d" && mk "$d" a.txt first
expect "first run with no state" silent "$(run_hook "$d" "git commit -m first")"

mkdir -p "$work/plain"
expect "non-repo cwd" silent "$(run_hook "$work/plain" "git commit -m x")"

d=$(new_repo corrupt)
echo garbage >"$(state "$d")"
expect "corrupt state resets silently" silent "$(run_hook "$d" "git status")"
mk "$d" c.txt after
expect "commit after a reset fires" fired "$(run_hook "$d" "git commit -m after")"

d=$(new_repo empty-state)
: >"$(state "$d")"
expect "empty state resets silently" silent "$(run_hook "$d" "git status")"

echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ]
