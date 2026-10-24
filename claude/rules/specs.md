## Specs

- Each repo has one central `docs/SPEC.md` stating current goals and intended behavior. It is the source of truth and evolves over time. This overrides skill defaults such as dated design files under `docs/superpowers/`. Why: dated specs alone drift from reality and nothing marks them as superseded.
- Size the work (quick task, small change, project). Only a project gets a folder: `docs/projects/YYYY-MM-DD-<type>-<slug>/SPEC.md`, plus scratch files. Types: `feature-`, `bug-<jira-id>`, `idea-`, `poc-`. A small change that alters behavior is a proposed `docs/SPEC.md` diff, with no folder.
- Files in a project are `<type>-<topic>.md`: `design`, `plan`, `proposal`, `testplan`, `learning`, `log`, `research`. Save plans there, overriding the writing-plans default location.
- Each doc starts with a header: `Type`, `Status`, `Supersedes/Amends` (when applicable), `Level` (designs only: `architecture`, `system`, `detailed`), and an optional `Audience`.
- ADRs and `GLOSSARY.md` stay repo-wide (`docs/adr/`, repo root), per the domain-modeling skill. SPECs link to them.
- A project is done only when its outcome is merged into `docs/SPEC.md`, tracked by a "Merge into SPEC" item (pending or merged, with commit). Propose the exact `docs/SPEC.md` diff and get my approval before applying it. Keep the project folder as history.
- A new repo's initial design seeds `docs/SPEC.md` and is recorded as its first project, including the interview questions and answers.
- If a spec has no repo yet, run a local `git init` and start it there. Ask before creating a remote. Never push.
- Design order: brainstorm interview, then ask whether there is anything else I want to cover, then grill the remaining open items. Record questions, answers and added items in the spec as they come up.
