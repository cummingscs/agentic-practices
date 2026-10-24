# OpenSpec: how change deltas merge into specs

- Type: research
- Status: draft
- Amends: `research-prior-art.md` (closes its OpenSpec verification task)
- Audience: me, and agents working on the spec convention

Public sources only. Read 2026-10-24 from the OpenSpec repo at tag `@fission-ai/openspec@1.15.0`, commit `8e0288df` (2026-10-24). The cited files are identical at `main` (`6d04a1b`) on that date (`git diff --stat 8e0288df 6d04a1b` over them was empty). Links below are pinned to that commit.

## Summary
OpenSpec merges requirement by requirement, matching on name. A change carries one delta file per capability, with `## ADDED`, `## MODIFIED`, `## REMOVED` and `## RENAMED Requirements` sections. On archive the CLI rebuilds each main spec. It applies the operations in a fixed order and replaces a whole `### Requirement:` block on MODIFIED. It validates every rebuilt spec before writing any of them, then moves the change folder to `changes/archive/YYYY-MM-DD-<name>/`. It records no base version, so it cannot see that a change is stale. Its only guard is narrower: a MODIFIED block that would drop a scenario the live spec still has is refused. Two changes that edit the same scenario's text still overwrite each other, last one wins. The project's own remediation plan names this gap, and the base-fingerprint fix it proposes is not implemented.

For this repo, three things are worth borrowing: named, addressable items in `docs/SPEC.md`, a delta written against those names, and a recorded base commit checked at merge time. All three cost a few lines of convention and no tooling.

## How OpenSpec merges deltas

**Layout.** Main specs live at `openspec/specs/<capability>/spec.md` (nested paths are allowed). A change is a folder ([B/docs/concepts.md](https://github.com/Fission-AI/OpenSpec/blob/8e0288df12d401b0e183e2f47254d22528c1dffb/docs/concepts.md), "Change Structure"):
```
openspec/changes/add-dark-mode/
├── proposal.md  design.md  tasks.md
├── .openspec.yaml        # optional: schema, skip_specs, retire_capabilities, x-* keys
└── specs/ui/spec.md      # delta for openspec/specs/ui/spec.md
```
The delta at `specs/<id>/spec.md` maps onto `openspec/specs/<id>/spec.md` ([B/src/core/specs-apply.ts#L120-L161](https://github.com/Fission-AI/OpenSpec/blob/8e0288df12d401b0e183e2f47254d22528c1dffb/src/core/specs-apply.ts#L120-L161)).

**Delta format.** Requirements are `### Requirement: <name>` blocks with `#### Scenario:` children. Renames are `FROM:`/`TO:` pairs ([B/src/core/templates/workflows/sync-specs.ts#L217-L224](https://github.com/Fission-AI/OpenSpec/blob/8e0288df12d401b0e183e2f47254d22528c1dffb/src/core/templates/workflows/sync-specs.ts#L217-L224)):
```markdown
## MODIFIED Requirements
### Requirement: Session Timeout
...full block, every surviving scenario...
## REMOVED Requirements
### Requirement: Remember Me
## RENAMED Requirements
- FROM: `### Requirement: Old Name`
- TO: `### Requirement: New Name`
```
Matching is by header name, case-sensitive, ignoring a closing `#` run. A case- and whitespace-insensitive fold is used only to flag near-miss typos ([B/src/core/parsers/requirement-blocks.ts#L17-L34](https://github.com/Fission-AI/OpenSpec/blob/8e0288df12d401b0e183e2f47254d22528c1dffb/src/core/parsers/requirement-blocks.ts#L17-L34)). A `## Purpose` in a delta only seeds a brand-new spec ([B/src/core/specs-apply.ts#L365-L386](https://github.com/Fission-AI/OpenSpec/blob/8e0288df12d401b0e183e2f47254d22528c1dffb/src/core/specs-apply.ts#L365-L386)).

*Docs and code disagree:* the delta-sections table in [B/docs/concepts.md](https://github.com/Fission-AI/OpenSpec/blob/8e0288df12d401b0e183e2f47254d22528c1dffb/docs/concepts.md) lists ADDED, MODIFIED, REMOVED and Purpose but not RENAMED. The code and [B/docs/commands.md](https://github.com/Fission-AI/OpenSpec/blob/8e0288df12d401b0e183e2f47254d22528c1dffb/docs/commands.md) (line 472) support RENAMED.

**Apply (`buildUpdatedSpec`).** Before touching the target, the delta is checked for internal consistency. It rejects duplicates within a section, a name that appears in two sections (for example MODIFIED and REMOVED), a MODIFIED that names a rename's old header, unpaired FROM/TO lines, and a delta with no operations ([B/src/core/specs-apply.ts#L227-L363](https://github.com/Fission-AI/OpenSpec/blob/8e0288df12d401b0e183e2f47254d22528c1dffb/src/core/specs-apply.ts#L227-L363)). For a new spec, only ADDED is allowed ([L392-L398](https://github.com/Fission-AI/OpenSpec/blob/8e0288df12d401b0e183e2f47254d22528c1dffb/src/core/specs-apply.ts#L392-L398)). Then:
```ts
// Apply operations in order: RENAMED → REMOVED → MODIFIED → ADDED
```
([B/src/core/specs-apply.ts#L446-L592](https://github.com/Fission-AI/OpenSpec/blob/8e0288df12d401b0e183e2f47254d22528c1dffb/src/core/specs-apply.ts#L446-L592))
- RENAMED: a missing source fails, unless the target already exists ("already synced"). A target that already exists fails.
- REMOVED: a missing name only warns ("treating it as already removed"), unless a near-miss spelling exists, which fails.
- MODIFIED: a missing name fails. Otherwise the block is replaced whole (`nameToBlock.set(key, mod)`).
- ADDED: an existing name with identical content is a no-op. Different content fails ("already exists").
- Original order is kept, and new blocks are appended ([L596-L655](https://github.com/Fission-AI/OpenSpec/blob/8e0288df12d401b0e183e2f47254d22528c1dffb/src/core/specs-apply.ts#L596-L655)).

These no-op rules make apply idempotent. A change can be synced into the main spec early (`/opsx:sync`) and archived later without double-applying.

**Archive (`openspec archive`).** The command validates the change, builds every rebuilt spec as a preview, and asks for confirmation. If any input file changed in the meantime, it rebuilds and compares, and aborts on a mismatch. Then it validates *all* rebuilt specs before writing any, writes them, and moves the folder. If a step fails, it restores spec snapshots, and refuses to restore over a concurrent edit ([B/src/core/archive.ts#L1706-L1880](https://github.com/Fission-AI/OpenSpec/blob/8e0288df12d401b0e183e2f47254d22528c1dffb/src/core/archive.ts#L1706-L1880), [B/src/core/archive.ts#L1136-L1225](https://github.com/Fission-AI/OpenSpec/blob/8e0288df12d401b0e183e2f47254d22528c1dffb/src/core/archive.ts#L1136-L1225); steps listed in [B/docs/cli.md](https://github.com/Fission-AI/OpenSpec/blob/8e0288df12d401b0e183e2f47254d22528c1dffb/docs/cli.md), "openspec archive"). Removing a capability's last requirement deletes its spec file, but only with `retire_capabilities: true` in `.openspec.yaml`.

**Validation.** `openspec validate` checks structure, and it also compares each MODIFIED block against the live main spec using the same scenario comparison archive applies ([B/src/core/validation/validator.ts#L695-L787](https://github.com/Fission-AI/OpenSpec/blob/8e0288df12d401b0e183e2f47254d22528c1dffb/src/core/validation/validator.ts#L695-L787)):
> MODIFIED "…" omits scenario(s) the current spec still has … a MODIFIED requirement replaces the whole block, so archive refuses to drop them.

**A second, agent-driven merge path.** The `/opsx:sync` skill (also used inline by `/opsx:archive`) tells the agent to "directly edit main specs", and to "preserve scenarios/content not mentioned in the delta" ([B/src/core/templates/workflows/sync-specs.ts#L17](https://github.com/Fission-AI/OpenSpec/blob/8e0288df12d401b0e183e2f47254d22528c1dffb/src/core/templates/workflows/sync-specs.ts#L17), [L110-L122](https://github.com/Fission-AI/OpenSpec/blob/8e0288df12d401b0e183e2f47254d22528c1dffb/src/core/templates/workflows/sync-specs.ts#L110-L122)). *Docs and code disagree:* this skill says an ADDED requirement that already exists is an "implicit MODIFIED". The CLI fails that case unless the content is identical ([B/src/core/specs-apply.ts#L565-L578](https://github.com/Fission-AI/OpenSpec/blob/8e0288df12d401b0e183e2f47254d22528c1dffb/src/core/specs-apply.ts#L565-L578)). The skill's later "Key Principle" section states the stricter whole-block rule again ([L247-L252](https://github.com/Fission-AI/OpenSpec/blob/8e0288df12d401b0e183e2f47254d22528c1dffb/src/core/templates/workflows/sync-specs.ts#L247-L252)). So the result depends on which path runs.

## Conflict handling

- **Two changes touching different requirements in one spec:** no conflict. Name-keyed blocks merge independently ([B/docs/concepts.md](https://github.com/Fission-AI/OpenSpec/blob/8e0288df12d401b0e183e2f47254d22528c1dffb/docs/concepts.md), "Conflict avoidance").
- **Two changes MODIFYing the same requirement:** last archive wins. The project documented this as silent data loss in [B/openspec-parallel-merge-plan.md](https://github.com/Fission-AI/OpenSpec/blob/8e0288df12d401b0e183e2f47254d22528c1dffb/openspec-parallel-merge-plan.md) (added 2025-10-14, PR #171): "When two changes touch the same requirement, the second archive overwrites the first and silently drops scenarios." Its root causes are "Replace-only semantics" and a "Missing base fingerprint".
- **What was fixed:** the dropped-scenario case, by scenario *name* (commit `7e21cc59`, 2026-07-08, "fix archive scenario drift", #1252). Archive and validate now refuse a MODIFIED block that lacks a scenario the live spec has ([B/src/core/specs-apply.ts#L549-L554](https://github.com/Fission-AI/OpenSpec/blob/8e0288df12d401b0e183e2f47254d22528c1dffb/src/core/specs-apply.ts#L549-L554)).
- **What was not fixed:** the plan's Phase 0/1, which would persist a base hash per touched requirement and add an `openspec change sync` rebase with conflict markers. A search of `src/` finds `fingerprint` only in archive-folder integrity checks and the preview-to-confirm re-check, with no `rebase` and no per-change base snapshot (`grep -rn -i "fingerprint\|rebase" src`). *Inferred from code, not tested:* if both changes edit the same scenario's text, or the requirement statement, and keep all scenario names, the second archive overwrites the first without a warning.
- **A delta that no longer matches the spec:** a MODIFIED or RENAMED source that is missing fails loudly. A REMOVED that is missing, or an ADDED or RENAMED that already exists with identical content, is a no-op, by design for early sync. Near-miss spellings fail.
- **Multi-change archive:** `/opsx:bulk-archive` defines a conflict as two or more changes with deltas for the same capability path. An agent then searches the codebase. If both changes are implemented, it applies them "in chronological order (older first, newer overwrites)" ([B/src/core/templates/workflows/bulk-archive-change.ts#L126-L156](https://github.com/Fission-AI/OpenSpec/blob/8e0288df12d401b0e183e2f47254d22528c1dffb/src/core/templates/workflows/bulk-archive-change.ts#L126-L156)). This is judgment, not a merge algorithm, and it resolves same-requirement edits by overwriting.

## What to borrow here
Each proposal maps onto `docs/SPEC.md` and the "Merge into SPEC" item in `claude/rules/specs.md`. Each would change `claude/` and so goes through codify-decision.

1. **Addressable items in `docs/SPEC.md`.** Give each behavior its own `###` heading under `## Behavior` (for example `### Install`, `### Commit checkpoint`) instead of bold-led bullets. *Benefit:* a delta and a review can name exactly what changes, and an agent can check that a named item exists. *Cost:* a one-time restructure of about 5 items. Headings make the file slightly longer.
2. **A "Spec delta" section in each project `SPEC.md`.** Write the delta as `ADDED` / `MODIFIED` / `REMOVED` / `RENAMED` lists keyed by item heading, with full replacement text for MODIFIED, as OpenSpec does. This *is* the proposed `docs/SPEC.md` diff that the "Merge into SPEC" step asks me to approve. Applying it follows OpenSpec's order (rename, remove, modify, add), and a name in two sections is an error. *Benefit:* the approval step reviews intent at item level rather than a raw diff, and the outcome of a skipped merge is visible. *Cost:* about 4 lines in `specs.md`, plus a short template. The agent applies it by hand; no CLI.
3. **Record a base, check it at merge.** When the delta is written, record `Base: <short hash of docs/SPEC.md's last commit>` next to the "Merge into SPEC" item. At merge time, run `git log <base>..HEAD -- docs/SPEC.md`. If any item named in the delta changed since then, rewrite the delta against the current text before proposing it. *Benefit:* closes the stale-delta overwrite that OpenSpec documents but has not fixed, using git instead of stored hashes. *Cost:* one header field and one command in the merge checklist.
4. **No-loss check for MODIFIED.** Before proposing, confirm that every sentence or sub-bullet in the current item is either kept or deliberately dropped and named in the proposal. This is OpenSpec's scenario-name guard, applied by the agent. *Benefit:* catches accidental truncation, which is the most common way a replace-whole-item merge loses content. *Cost:* one checklist line.
5. **Idempotent merge.** State that applying a delta whose items already match the spec is a no-op. *Benefit:* an outcome can be merged early (for example after a first commit) and re-checked at close without double edits. *Cost:* one sentence.

## Not worth borrowing
- **The CLI and parsers.** Thousands of lines handle markdown edge cases (fences, foreign headings, symlinked capability directories, path containment). One human-reviewed `docs/SPEC.md` does not need this, and the approval step already reviews every merge.
- **Per-capability spec files.** A single SPEC is the point of the convention here. Revisit only if `docs/SPEC.md` outgrows one file. That would be a Considerations entry, not now.
- **Moving project folders to an archive directory.** Project folders here already stay in place as history. A `Status` header plus the "Merge into SPEC: merged (<commit>)" line marks them done.
- **Retirement markers (`retire_capabilities`).** That machinery exists to guard file deletion. Here, removing a section is an ordinary REMOVED item in an approved diff.
- **Agent-judged bulk merging by codebase inspection.** It resolves conflicts by "newer overwrites", which is the failure item 3 is meant to prevent.
- **Mandatory GIVEN/WHEN/THEN scenarios.** They are useful for product specs, but heavy for a spec about personal working practices. Keep them optional.

## Sources
All read 2026-10-24 at commit `8e0288df12d401b0e183e2f47254d22528c1dffb` (tag `@fission-ai/openspec@1.15.0`):
- https://github.com/Fission-AI/OpenSpec/blob/8e0288df12d401b0e183e2f47254d22528c1dffb/src/core/specs-apply.ts
- https://github.com/Fission-AI/OpenSpec/blob/8e0288df12d401b0e183e2f47254d22528c1dffb/src/core/archive.ts
- https://github.com/Fission-AI/OpenSpec/blob/8e0288df12d401b0e183e2f47254d22528c1dffb/src/core/validation/validator.ts
- https://github.com/Fission-AI/OpenSpec/blob/8e0288df12d401b0e183e2f47254d22528c1dffb/src/core/parsers/requirement-blocks.ts
- https://github.com/Fission-AI/OpenSpec/blob/8e0288df12d401b0e183e2f47254d22528c1dffb/src/core/templates/workflows/sync-specs.ts
- https://github.com/Fission-AI/OpenSpec/blob/8e0288df12d401b0e183e2f47254d22528c1dffb/src/core/templates/workflows/bulk-archive-change.ts
- https://github.com/Fission-AI/OpenSpec/blob/8e0288df12d401b0e183e2f47254d22528c1dffb/openspec-parallel-merge-plan.md
- https://github.com/Fission-AI/OpenSpec/blob/8e0288df12d401b0e183e2f47254d22528c1dffb/docs/concepts.md
- https://github.com/Fission-AI/OpenSpec/blob/8e0288df12d401b0e183e2f47254d22528c1dffb/docs/cli.md
- https://github.com/Fission-AI/OpenSpec/blob/8e0288df12d401b0e183e2f47254d22528c1dffb/docs/commands.md
- Commits: https://github.com/Fission-AI/OpenSpec/commit/7e21cc59 (scenario-drift guard, 2026-07-08); https://github.com/Fission-AI/OpenSpec/commit/fe83be5d (parallel merge plan, 2025-10-14)

Unverified: runtime behavior. Nothing was executed; all claims come from reading the source and docs. Verification task: in a scratch checkout, archive two changes that MODIFY the same scenario's text, and confirm the silent overwrite inferred above.
