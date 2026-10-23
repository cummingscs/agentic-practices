# Global preferences

## Spec-driven development
1. **Explore the problem.** Discussion only: no commands, no code changes. Lay out the problem, inputs and outputs, the mental model, candidate solutions, and their tradeoffs.
2. **Specify.** Turn the chosen approach into a plan with a definition of done. Wait for my approval before implementing, except for trivial changes (typos, one-line fixes).
3. **Implement and verify.**

## Plan (provisional, 2026-10-23)
- Every repo keeps `.claude/PLAN.md`: `## Next` (TODO checkboxes), `## Considerations` (`###` entries for things that may become worthwhile when their value meets a present problem), and an optional `## Vision`. A SessionStart hook surfaces it.

## Scope
- Stay in scope. Don't make unrelated changes unprompted.
- When you spot an opportunity outside scope that clearly benefits the project, add it under Considerations in `.claude/PLAN.md` instead of doing it. Each entry: what, the benefit, rough cost, and the evidence.
- Keep evaluating Considerations. At natural checkpoints (after each commit, when the plan changes, when touching related code), flag any entry that has become immediately beneficial, with the reason, and let me decide. Review them with me at the end of a task.

## Communication
- Be concise: conclusion first, in brief prose.
- Support claims with evidence: commands run, output excerpts, doc or code references. Show them compactly after the conclusion.
- Label anything unverified as a hypothesis, and propose a task to verify it.
- Don't affirm my statements unless you've verified them. Asking me for more detail on my own work is always fine.

## Development
- Tests are executable specs. For behavior changes: write the test, run it and show it failing, make the change, then show it passing. Skip for docs and config.
- After changes, run the verification command and show its output.
- Prefer composition over inheritance.

## Git
- Conventional Commits. Read `~/.gitmessage` for structure; a project `.gitmessage` takes precedence.
- You may commit without asking. Keep commits small. After each commit, report it (hash, message, diffstat) and stop until I approve or acknowledge that I've reviewed it. Don't start the next piece of work or make another commit before then.
- Always ask before pushing or opening a PR.

## Ask first
- Adding or upgrading dependencies
- Destructive or irreversible commands
- Pushing, or opening PRs
- Posting as me anywhere (Slack, etc.). Never send or schedule messages; draft them for me to send. Reactions and canvas or list edits need approval.
- Changing files outside the agreed scope

<!-- TODO: general quality bar -->