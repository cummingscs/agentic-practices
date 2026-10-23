---
name: codify-decision
description: Turn a decision, boundary, or working agreement from the current conversation into the right durable artifact (CLAUDE.md, .claude/rules, a skill, a permission rule, or a hook). Use when the user says "codify this", "make that a rule", "remember that", "add that to CLAUDE.md", "never do X", or when a correction has been repeated and should stick. Proposes diffs; never writes without approval.
argument-hint: "[optional: the decision to codify; defaults to the most recent agreement in the conversation]"
---

# Codify a decision

Convert something we agreed in conversation into a repeatable, enforced practice in the correct place.

## 1. Extract the decision

State it back as one imperative sentence plus a one-line *why*. If the conversation holds several decisions, list them and handle each separately. If the decision is ambiguous, ask one clarifying question before continuing.

## 2. Gather evidence

Before classifying, collect the data points that support (and contradict) the decision. Search what is available:

- The current conversation: where it was stated, and whether it was a decision or a passing thought.
- Prior sessions and memory: repeated corrections or the same preference stated before.
- Git history and PR review comments: the same feedback given more than once, reverts, or fixes for the same class of mistake.
- Incidents, postmortems, tickets, or docs that motivated the rule.
- Project learnings and decision records: `learning-*` and `log-*` docs under `docs/projects/`, `docs/adr/`, and Considerations in `.claude/PLAN.md`. These are the usual sources when promoting something learned in one project.
- Existing rules or code that already follow (or violate) it.

Present a short evidence table: source, what it shows, and whether it supports or contradicts. Include counter-examples and known exceptions, since they sharpen the rule's wording.

Then rate the strength:

- **Strong** (3+ independent data points, or one high-impact incident): proceed to classify.
- **Moderate** (2 data points): proceed, but prefer a narrower scope or lighter mechanism, and say why.
- **Weak** (1 data point, or only this conversation): ask the user whether to codify now as a provisional rule (marked with its date, the reason, and a review-by date) or hold and watch for recurrence.

Do not invent or stretch evidence. If a source could not be searched, say so rather than implying there is none. Record the key evidence in the rule's rationale or the PR description so future reviewers can see why it exists.

## 3. Classify

Pick the lightest mechanism that is reliable enough:

| The decision is... | Mechanism | Location |
|---|---|---|
| A preference or expectation Claude should usually follow | Guidance | `CLAUDE.md` (short) or `.claude/rules/<topic>.md` (longer, can be path-scoped) |
| A multi-step procedure with a definition of done | Skill | `.claude/skills/<name>/SKILL.md` |
| A limit that must never be violated, or needs approval | Permission rule | `settings.json` `deny` / `ask` / `allow` |
| A check that must run automatically on an event | Hook | `settings.json` `hooks` |
| A role needing isolated context or restricted tools | Subagent | `.claude/agents/<name>.md` |
| A product or behavior decision: what the system must do, or why it was designed this way | Spec or ADR | `docs/SPEC.md` (merge-back needs approval) or `docs/adr/NNNN-<slug>.md` |

Escalation rule: if the user says the rule has been ignored before, or the cost of violation is high (data loss, secrets, production, force-push), prefer a permission or hook over guidance. Guidance can be paired with enforcement; say when you recommend both.

## 4. Choose the scope

- **Global, repo-managed** (default when the user keeps a practices repo; check with `readlink ~/.claude/CLAUDE.md`): the repo's `claude/` tree (`claude/CLAUDE.md`, `claude/rules/`, `claude/skills/`, `claude/hooks/`), symlinked into `~/.claude/`. True for this user in every repo, and worth versioning and reviewing. A new rules file is picked up once linked, so tell the user to run the repo's installer.
- **Global, machine-local** (real files in `~/.claude/`): true for this user in every repo, but specific to this machine or not worth versioning.
- **Project, shared** (`<repo>/CLAUDE.md`, `.claude/`, checked in): true for anyone working in this repo.
- **Project, local** (`CLAUDE.local.md`, `settings.local.json`, gitignored): personal to this user in this repo.

Test: would a teammate want this? Project, shared. Only the user, everywhere? Global (repo-managed unless machine-specific). Only the user, only here? Local. If unsure, ask.

Promotion to global is a normal path: when a project rule or learning proves general, move it to the global home, remove it from the project file, and mark the source (see Confirm).

## 5. Check before writing

- Read the target file and its neighbors. Look for an existing rule that already covers it, overlaps, or conflicts. Prefer editing or merging over adding.
- Confirm the same rule is not already present at another scope.
- Keep `CLAUDE.md` short. If adding would push it past ~200 lines, move content to `.claude/rules/` and leave a pointer.
- Write rules as specific, verifiable statements ("Run `cargo test` before proposing a commit"), not vague ideals ("write good tests"). Include the why when it is non-obvious.

## 6. Propose, don't apply

Show for each change: the target file, the exact diff, and a one-line rationale for the mechanism and scope chosen. Then ask for approval. Apply only what is approved, one file at a time.

For permission rules and hooks, also show what will now be blocked or prompted, and one example command that would trigger it.

## 7. Confirm

After applying, summarize in one or two lines: what changed, where, and how it will take effect (CLAUDE.md edits apply next session or after `/memory` reload; settings changes apply on next prompt). If the change is in a checked-in file, remind the user it is not yet committed and suggest it go through PR review.

If the decision was promoted from a project learning or rule, mark the source `Promoted: <where>, <date or commit>` and link back to the source from the new rule's rationale, so provenance survives and the same item is not promoted twice.

## Boundaries

- Never edit managed or organization-level policy files.
- Never loosen an existing `deny` or `ask` rule without the user explicitly saying so.
- Never add broad `allow` rules (such as `Bash(*)`) to make a prompt go away; scope them to specific commands.
- Do not codify something the user only mused about. If it was not a decision, say so and move on.
- Never put employer-confidential or private details in a shared or versioned rule file. Generalize the rationale, and name no internal repos, tickets, URLs or figures.