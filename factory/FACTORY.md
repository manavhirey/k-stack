# Factory working agreement

<!-- Imported from CLAUDE.md with `@factory/FACTORY.md`.
     Last reviewed: 2026-11-19. Run /tune-instructions at least monthly or after a model upgrade.
     Stable conventions and genuine boundaries only. Task-specific requirements
     go in the brief. Limits are enforced in .claude/settings.json; this file
     only explains them. -->

## How work runs here

Substantial work follows the factory loop: **brief → build → review → verify**.

- Every substantial assignment starts from a brief in `factory/work/<slug>/brief.md` (template: `factory/templates/brief.md`). If there is no brief, write one with `/brief` before implementing. Small, obvious fixes don't need one.
- Work ends with a report in the format of `factory/templates/report.md`: what changed, why, evidence, remaining uncertainty, what's needed from the user.
- Consequential changes get an independent review with `/factory-review`, then `/factory-verify` after fixes.
- Before switching model or session, or at a milestone in long work, write a handoff with `/handoff`.

## Working rules

- Verify, don't predict: run the check and quote the result. Match evidence to the claim.
- Routine failures are not stopping points. Diagnose and retry; change approach after the same failure twice.
- Stop and ask when a criterion looks wrong, the fix needs out-of-scope changes, or an action needs approval under the brief's autonomy rules.
- Before escalating model or effort, name the failure: missing context, insufficient checking, or beyond capability. See `docs/model-and-effort.md`.
- Delegate to subagents only for independent work you can specify exactly. See `.claude/agents/`.

## Boundaries

Enforced by `.claude/settings.json` (deny > ask > allow). Summary:

- Denied: force-push, hard reset of shared branches, reading `.env`/secrets/keys, deploy and infra-apply commands.
- Ask first: `git push`, merge/rebase/reset, opening/merging PRs, installing dependencies, `rm`, network fetches, `docker`.
- Allowed: reading, editing in the repo, running tests/linters/builds, local git commits and branches.
