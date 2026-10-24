# agentic-practices: Spec

- Type: spec
- Status: active (seeded 2026-10-23 from `projects/2026-10-23-project-initial-practices`)

## Purpose
A versioned home for my reusable Claude Code configuration, and a place to evolve how I use agents systematically, with evidence. Also a worked example of the spec convention it defines.

## Principles
- **Versioned and reviewable.** Global behavior comes from files in this repo, not hand-edited state in `~/.claude`.
- **Installed by symlink.** `claude/` mirrors `~/.claude`; files link individually; edits apply immediately.
- **Evidence over assertion.** Rules change through the codify-decision flow; weak evidence is marked provisional with a date.
- **Safe to publish.** Public sources only; rationale is generalized.

## Behavior
- **Install:** `/install-practices` checks and applies symlinks and merges the hook registrations declared in `claude/settings.fragment.json` into `~/.claude/settings.json`, each step with approval, backing up conflicts and never deleting or duplicating.
- **Commit checkpoint:** `claude/hooks/commit-checkpoint.sh` enforces the "report each commit and pause for review" rule from `claude/CLAUDE.md`. It fires when HEAD's reflog gained a commit-creating entry (commit, amend, finished rebase, merge commit, cherry-pick, revert) since its last run in that repo, never on command text alone. Pulls, fetches, checkouts and failed or dry-run commits stay silent.
- **Specs:** one central `docs/SPEC.md` per repo; efforts as dated project folders; merge-back into the SPEC needs approval; documents carry a header (`Type`, `Status`, `Supersedes/Amends`, `Level`, `Audience`). Details in `claude/rules/specs.md`.
- **Plan:** every repo keeps `.claude/PLAN.md` with Next, Considerations and an optional Vision. `claude/hooks/surface-plan.sh` surfaces the open TODO count and Consideration titles at session start.
- **Decisions:** `codify-decision` places a decision in the lightest reliable mechanism and scope, with global split into repo-managed and machine-local homes.

## Out of scope (for now)
Plugin packaging, an installer script beyond the skill, and sharing with others. See Considerations in `.claude/PLAN.md`.

## Open questions
Tracked in `.claude/PLAN.md` and in the project's "Open threads".
