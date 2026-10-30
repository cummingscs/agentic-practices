# Plan

## Next
- [x] Review the initial commit: layout, the specs rule, the PLAN convention, and the codify-decision edits.
- [x] Run `/install-practices` (check mode first) to symlink `claude/` into `~/.claude`, then confirm in a fresh session that the rules load (`/memory`).
- [x] Register both hooks (`surface-plan.sh`, `commit-checkpoint.sh`) via the installer's fragment merge, confirm the existing commit-checkpoint entry is not duplicated, and confirm the plan hook prints in a new session.
- [x] Verify Claude Code discovers `.claude/skills/install-practices` when started in this repo.
- [x] Decide which OpenSpec practices to adopt into `claude/rules/specs.md` (via codify-decision). Adopted merge safety (base check, no-loss check) on 2026-10-30; see `docs/projects/2026-10-23-project-initial-practices/research-openspec.md`.
- [x] Fix `claude/hooks/commit-checkpoint.sh` false positives: it fires on any Bash command whose text contains "git commit" (observed on an `echo` test input) and never checks that the commit succeeded, so its "a commit was just made" message can be wrong. Match only a real `git commit` invocation and check success. Write the test first (failing, then passing).
- [ ] Fix the Slack permission rules in the local `~/.claude/settings.json`: the deny/ask rules name `mcp__claude_ai_Slack__*` tools, but Slack is loaded from the `slack` plugin as `mcp__plugin_slack_slack__*`, so the rules never match and "never send" rests on instructions alone. Authenticate the plugin, list its real tool names, rewrite the rules (consider a wildcard for send/schedule), then confirm a send attempt is denied. Decide whether permissions belong in `claude/settings.fragment.json`. Once fixed, revisit making `auto` the default permission mode (deferred by `/doctor` on 2026-10-24 pending this fix).
- [ ] Restructure the `steven-as-an-mcp` draft design to this repo's spec layout (`docs/SPEC.md` plus a dated project folder), per `claude/rules/specs.md`.
- [x] Add a step 0 to `install-practices`: `git fetch` (warn and continue if offline), then report the tree state. Behind or diverged: stop and suggest `git pull` (or rebase), then rerun. Ahead: note unpushed commits. Dirty: note that uncommitted edits in `claude/` are already live. Never pull automatically. Why: a routine reminder to pull, not only for a second machine.

## Considerations

### Split the global CLAUDE.md into topic rule files
- **What:** move each section of `claude/CLAUDE.md` into `claude/rules/<topic>.md`, leaving `CLAUDE.md` short.
- **Benefit:** smaller always-loaded file, topics can be scoped or reused independently.
- **Cost:** small; a handful of files and re-linking.
- **Evidence:** the docs advise under 200 lines per CLAUDE.md; today it is about 40, so not yet pressing.

### Package skills and hooks as narrow plugins
- **What:** bundle a coherent set (for example spec skills plus the plan hook) as a plugin.
- **Benefit:** one-command install and versioning when sharing with others.
- **Cost:** moderate; plugin skills are namespaced, installs are copies (no live editing), and every enabled plugin adds context cost.
- **Evidence:** per the plugin docs, plugins bundle skills, agents, hooks and MCP servers; rules and CLAUDE.md are not listed as plugin content (unverified).

### Stop the global CLAUDE.md loading twice in this repo
- **What:** keep `claude/CLAUDE.md` from loading as a repo file on top of its `~/.claude/CLAUDE.md` symlink, for example by renaming the source (and the installer mapping) or excluding the path from memory loading (unverified whether a setting for that exists).
- **Benefit:** about 660 est. tokens per session in this repo, and one copy of the global rules instead of two.
- **Cost:** small; a rename plus installer and doc references, or one setting.
- **Evidence:** at the start of a 2026-10-23 session the same content appeared both as `agentic-practices/claude/CLAUDE.md` and as `~/.claude/CLAUDE.md` (found by `/doctor`). Why the nested file loads at startup is unverified.

### Addressable `###` items in `docs/SPEC.md`
- **What:** give each Behavior item its own `###` heading instead of a bold-led bullet (OpenSpec borrow, item 1 in `research-openspec.md`).
- **Benefit:** tooling or a delta can name and check items exactly.
- **Cost:** one-time restructure of about 5 items; slightly longer file.
- **Evidence:** bold labels are unique today, so deltas can already name items. Trigger: a parser, or ambiguous labels.

### Item-level "Spec delta" section in project SPECs
- **What:** write merges as `ADDED` / `MODIFIED` / `REMOVED` / `RENAMED` lists keyed by item, applied in that order (OpenSpec borrow, item 2 in `research-openspec.md`).
- **Benefit:** reviews intent at item level rather than a raw diff.
- **Cost:** about 4 lines in `claude/rules/specs.md` plus a short template.
- **Evidence:** `docs/SPEC.md` has 5 behavior items and no project merge since seeding, so a raw diff is easy to review. Trigger: a merge touching several items, or a diff hard to review.

### An `ideas` repo for idea-stage specs
- **What:** a small repo holding `idea-` projects that have no home repo yet, marked `graduated` when they move.
- **Benefit:** a place for specs that may never become repos.
- **Cost:** low, but only worth creating at the first real case.
- **Evidence:** the repo-first rule covers the common case; this is for the exception.

## Vision
Evolve how I use agents systematically, with evidence. Topics to work through here over time: superpowers usage (workflow defaults and path overrides), a skills inventory and lifecycle (what earns its context cost), MCP server management, agents and subagents, hooks and permissions, plugin evaluation, and measuring whether practices help.
