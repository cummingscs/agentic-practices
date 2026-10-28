# Initial practices

- Type: spec
- Status: active
- Merge into `docs/SPEC.md`: merged (seeded in the initial commit)

## Intent
Capture the practices I want as global defaults, make them reusable and versioned, and keep evolving them. This project records the initial design conversation, including the interview, so later work can continue it.

## Interview record
- **One spec per feature, or one evolving spec?** A central `docs/SPEC.md` for current goals and behavior, plus dated project folders for efforts, merged back on completion. Project folders keep scratch space.
- **Is a spec the same as a design?** No. A SPEC states what must be true; designs say how (level and audience go in headers); ADRs record why; plans are derived steps.
- **Anything else before the open questions?** Yes: ask this explicitly after the interview, and record the items.
- **Should the merge-back be implicit?** No. Propose the diff and wait for approval; track it as a checklist item so a skip is visible.
- **How should shared memory work?** Anything a teammate needs lives in the repo; personal preferences stay in user memory; learnings are promoted to rules through codify-decision.
- **Where do global rules live?** In this repo under `claude/`, symlinked into `~/.claude`. User-level rules in `~/.claude/rules/` load automatically.
- **How do TODOs surface?** Per-repo `.claude/PLAN.md` plus a SessionStart hook. It replaces the earlier opportunities queue.
- **Plugin or symlinks?** Symlinks and an installer skill for now; narrow plugins later if sharing warrants.
- **Specs with no repo yet?** Repo-first: run a local `git init` and start there; ask before creating a remote.

## Decisions
- [decided] Central SPEC plus dated project folders; file prefixes `design`, `plan`, `proposal`, `testplan`, `learning`, `log`, `research`; ADRs and glossary stay repo-wide.
- [decided] `claude/` mirrors `~/.claude`; `claude/skills/` ships skills; `.claude/skills/install-practices` is this repo's own.
- [decided] `.claude/PLAN.md` in every project; the opportunities queue is retired.
- [decided] Hooks and their registrations are versioned here: scripts in `claude/hooks/`, registrations in `claude/settings.fragment.json`, merged idempotently by the installer.
- [my call, minor] `Level` values for designs are `architecture`, `system` and `detailed`; implementation logs are a separate `log` type.
- [decided] Personal commit identity for this repo; nothing employer-internal is committed.
- [verified] Project skills in `.claude/skills/` are discovered when Claude Code starts in this repo (confirmed after install; see `.claude/PLAN.md`).

## Evidence
See `research-prior-art.md` for public sources. Local evidence: no repo had an opportunities queue file, consistent with it not being surfaced; the PLAN convention is therefore provisional.

## Open threads
- Superpowers usage: brainstorming asks one open question at a time, grilling asks a round with recommended answers; we sequence them (brainstorm, "anything else", grill). Revisit once used in practice.
- Skills inventory and lifecycle; MCP management; agents and subagents; hooks and permissions.
- The `steven-as-an-mcp` repo is a lab consumer; its draft design should be restructured to this layout (tracked in `.claude/PLAN.md`).
- Resolved: OpenSpec's merge mechanics are researched in `research-openspec.md` (adoption decision tracked in `.claude/PLAN.md`); skill discovery and hook output were verified after install.
