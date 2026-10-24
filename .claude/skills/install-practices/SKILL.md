---
name: install-practices
description: Check or apply the symlinks that install this repo's claude/ tree (CLAUDE.md, rules, skills, hooks) into ~/.claude, and register the plan hook in settings. Use when setting up a machine, after adding files under claude/, or to check for drift.
disable-model-invocation: true
---

# Install practices

Install the contents of this repo's `claude/` tree into `~/.claude` by symlink, so edits here apply immediately. Run only from the root of this repo.

## Mapping

| Source (this repo) | Target |
|---|---|
| `claude/CLAUDE.md` | `~/.claude/CLAUDE.md` |
| `claude/rules/<file>.md` | `~/.claude/rules/<file>.md` |
| `claude/skills/<name>/` | `~/.claude/skills/<name>` |
| `claude/hooks/<file>` | `~/.claude/hooks/<file>` |
| `claude/settings.fragment.json` | merged into `~/.claude/settings.json`, not symlinked (see step 4) |

Link each file or skill directory individually, never a whole parent directory, so machine-local files can coexist.

## 0. Check for upstream updates (always first)

The links point at this checkout, so a stale checkout means stale config everywhere. Run `GIT_TERMINAL_PROMPT=0 git fetch --quiet` (the variable stops an auth prompt from hanging). If it fails (offline, auth) or the branch has no upstream, say so in one line and continue with step 1 against local state.

Otherwise classify with `git rev-list --left-right --count HEAD...@{u}` (ahead, then behind) and `git status --porcelain`:

- **Behind** (ahead 0, behind N): stop. Suggest `git pull`, then rerunning this skill.
- **Diverged** (both nonzero): stop. Suggest `git pull --rebase` or resolving by hand, then rerunning.
- **Ahead** (behind 0): note the N unpushed commits and continue.
- **Dirty**: list uncommitted paths under `claude/` and note they are already live in every session, then continue.
- **Up to date and clean**: say so in one line and continue.

Never pull, rebase or push yourself; only suggest it.

## 1. Check links

Confirm the working directory has `claude/` and `README.md`. For every source in the mapping, compute its target and classify it with `readlink`:

- **OK**: the target is a symlink to the source.
- **MISSING**: nothing at the target.
- **DRIFT**: the target is a symlink to somewhere else.
- **CONFLICT**: the target is a real file or directory.

For `claude/settings.fragment.json`, classify each hook entry (same event, matcher and command) as **REGISTERED** or **UNREGISTERED** in `~/.claude/settings.json`.

Show the table. If everything is OK and REGISTERED, say so and stop.

## 2. Propose

List the exact operations: `mkdir -p` for missing parents, a backup for each CONFLICT (move it to `~/.claude/backups/practices-<timestamp>/` keeping its relative name; never delete), then `ln -s <absolute source> <target>`. For DRIFT, show where the link points now and ask before replacing it. Ask for approval.

## 3. Apply

Run only the approved operations. Do not touch `~/.claude/skills/synced`, anything under `~/.claude/plugins`, or network paths.

## 4. Hook registration (separate approval)

`claude/settings.fragment.json` declares which hooks to register. For each UNREGISTERED entry, show the resulting change to `~/.claude/settings.json` and ask before writing. Merge rules:

- Add an entry only if no existing entry has the same event, matcher and command, so a hook that is already registered is never duplicated.
- Keep every existing setting and hook. Never remove or reorder anything.
- Back up `settings.json` first, into the same backups directory as in step 2.
- Entries with no matcher are intentional: they run on every session start.

## 5. Verify

Re-run the check and show every row OK and REGISTERED. Tell the user to start a new session and verify two things:

- Run `/memory` in the CLI, not the VSCode extension, to confirm the linked CLAUDE.md and rules are listed. The extension's dialog shows only auto-memory.
- In a repo with `.claude/PLAN.md`, ask "what do you know about PLAN.md before reading any file?". The hook's output goes into the model's context, not the UI, so the answer should cite the open TODO count and Consideration titles.

## Boundaries

- Never delete or overwrite without a backup and approval.
- Never run outside this repo.
- Report anything unverified (for example, if `/memory` does not list a linked file) as a hypothesis.
