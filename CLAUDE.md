# agentic-practices

This repo holds my reusable Claude Code configuration and is where I evolve how I work with agents. This file steers work *in this repo*. My global instructions live in `claude/CLAUDE.md`, which is a different file with a different job.

## On session start
- Read `docs/SPEC.md` and `.claude/PLAN.md`, then the "Open threads" in the latest `docs/projects/*/SPEC.md`, and resume from there.
- Topics to keep expanding: superpowers usage, skills inventory and lifecycle, MCP management, agents and subagents, hooks and permissions, plugins.

## Layout
- `claude/` mirrors `~/.claude` and is installed by symlink. Changes here affect every session I run, so treat them as global config.
- `claude/skills/` are skills delivered from this repo. `.claude/skills/` are this repo's own (for example `install-practices`).
- `docs/SPEC.md` is the central spec. Efforts live in `docs/projects/YYYY-MM-DD-<type>-<slug>/`. The convention is in `claude/rules/specs.md`; follow it here.

## Working agreements
- Change `claude/` through the codify-decision flow: state the decision, gather evidence, propose the diff, wait for approval. Mark weak evidence as provisional with a date.
- Everything committed here must be safe to publish. Use public sources only. Generalize rationale. Name no employer-internal repos, tickets, URLs, channels or figures. Grep staged files for such terms before each commit.
- Commit as my personal identity: verify the repo-local `git config user.email` before committing.
- Conventional Commits per `~/.gitmessage`. Small commits. Ask before pushing.
- Keep this file and `claude/CLAUDE.md` short. Move detail into rules or docs.
