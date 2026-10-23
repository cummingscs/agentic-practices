# Prior art: spec-driven development

- Type: research
- Status: active

Public sources only. Read 2026-10-23.

## Sources and findings
- **Martin Fowler, "Understanding Spec-Driven-Development: Kiro, spec-kit, and Tessl"** (`martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html`):
  - Three levels: spec-first, spec-anchored, spec-as-source. The tools examined are mostly spec-first.
  - Spec Kit creates a branch per spec, so a spec tends to live for one change. A central, maintained spec (spec-anchored) is the less proven path.
  - Criticisms: one heavy workflow for every size of task, many verbose markdown files to review, and a false sense of control when agents ignore instructions.
- **Spec Kit** (`github.com/github/spec-kit`, MIT per its site): commands for constitution, specify, clarify, plan, tasks, analyze and implement. The site does not describe file layout or how specs evolve.
- **OpenSpec** (`openspec.dev`, MIT): lifecycle of explore, propose, apply, verify, archive; a change holds `proposal.md`, `specs/`, `design.md` and `tasks.md`. The page does not describe how change deltas merge back into specs. Verification task: read its docs or repo.
- **Galileo, "Specification-first AI development"** (`galileo.ai/blog/specification-first-ai-development`): treat minor clarifications differently from fundamental changes, which need approval; version specs and record why a decision was made; make every requirement testable; start with a minimal spec.
- **Claude Code docs** (`code.claude.com/docs`): `~/.claude/rules/` applies to every project and supports symlinks; user-scope files load without an approval dialog; imports accept `~` paths with a depth limit of four; SessionStart hooks can inject context via stdout or `additionalContext`; plugins bundle skills, agents, hooks and MCP servers.

## Implications for this repo
- Our model is spec-anchored, so merge-back discipline is the likely failure point: it is explicit, approved and tracked.
- Size the work, so small changes skip the project folder and avoid the one-workflow-fits-all trap.
- Record why, not just what, via ADRs and the `Supersedes/Amends` header.
