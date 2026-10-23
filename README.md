# agentic-practices

Reusable Claude Code configuration and a place to evolve how I work with agents: global instructions, rules, skills, hooks, and notes on spec-driven development.

## Layout

| Path | Purpose |
|---|---|
| `claude/` | Mirrors `~/.claude`. Everything here is installed into `~/.claude` by symlink. |
| `claude/CLAUDE.md` | My global instructions (not this repo's own steering). |
| `claude/rules/` | Global rules, loaded automatically from `~/.claude/rules/`. |
| `claude/skills/` | Skills delivered from this repo (`codify-decision`). |
| `claude/hooks/` | Hook scripts: `surface-plan.sh` shows `.claude/PLAN.md` at session start; `commit-checkpoint.sh` reminds Claude to report and pause after each commit. `commit-checkpoint.sh` needs `jq` and exits silently without it. |
| `claude/settings.fragment.json` | Hook registrations, merged into `~/.claude/settings.json` by the installer. |
| `CLAUDE.md` | This repo's own steering. |
| `.claude/` | This repo's own plan (`PLAN.md`) and skills (`install-practices`). |
| `docs/` | This repo's spec and project history, following `claude/rules/specs.md`. |

## Install

Files are symlinked, not copied, so edits here apply immediately. Each file links individually, so machine-local files can coexist in `~/.claude`.

Start Claude Code in this repo and run `/install-practices`. It checks first, then applies each step only with your approval, backing up any real file it would replace.

By hand, for the two core files:

```bash
# keep a backup of any real file before replacing it
ln -s "$PWD/claude/CLAUDE.md" ~/.claude/CLAUDE.md
mkdir -p ~/.claude/rules
ln -s "$PWD/claude/rules/specs.md" ~/.claude/rules/specs.md
```

Rules in `~/.claude/rules/` apply to every project on the machine. Per the Claude Code docs, symlinks are supported there and user-level files load without an approval dialog.
