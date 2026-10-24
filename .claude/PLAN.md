# Plan

## Next
- [ ] Review the initial commit: layout, the specs rule, the PLAN convention, and the codify-decision edits.
- [ ] Run `/install-practices` (check mode first) to symlink `claude/` into `~/.claude`, then confirm in a fresh session that the rules load (`/memory`).
- [ ] Register both hooks (`surface-plan.sh`, `commit-checkpoint.sh`) via the installer's fragment merge, confirm the existing commit-checkpoint entry is not duplicated, and confirm the plan hook prints in a new session.
- [ ] Verify Claude Code discovers `.claude/skills/install-practices` when started in this repo.
- [ ] Verify how OpenSpec merges change deltas back into specs (read its docs or repo) and decide what to borrow.
- [ ] Fix `claude/hooks/commit-checkpoint.sh` false positives: it fires on any Bash command whose text contains "git commit" (observed on an `echo` test input) and never checks that the commit succeeded, so its "a commit was just made" message can be wrong. Match only a real `git commit` invocation and check success. Write the test first (failing, then passing).
- [ ] Fix the Slack permission rules in the local `~/.claude/settings.json`: the deny/ask rules name `mcp__claude_ai_Slack__*` tools, but Slack is loaded from the `slack` plugin as `mcp__plugin_slack_slack__*`, so the rules never match and "never send" rests on instructions alone. Authenticate the plugin, list its real tool names, rewrite the rules (consider a wildcard for send/schedule), then confirm a send attempt is denied. Decide whether permissions belong in `claude/settings.fragment.json`.

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

### An `ideas` repo for idea-stage specs
- **What:** a small repo holding `idea-` projects that have no home repo yet, marked `graduated` when they move.
- **Benefit:** a place for specs that may never become repos.
- **Cost:** low, but only worth creating at the first real case.
- **Evidence:** the repo-first rule covers the common case; this is for the exception.

## Vision
Evolve how I use agents systematically, with evidence. Topics to work through here over time: superpowers usage (workflow defaults and path overrides), a skills inventory and lifecycle (what earns its context cost), MCP server management, agents and subagents, hooks and permissions, plugin evaluation, and measuring whether practices help.
