# Brief: <short title>

<!--
A brief is the single source of truth for one assignment. Implementers build
against it, the reviewer checks against it, and the final report answers it.
Temporary requirements live here, not in CLAUDE.md.
Fill every section. "None" is a valid answer; a blank is not.
-->

- **Slug:** <kebab-case-id>  (work folder: `factory/work/<slug>/`)
- **Requested by:** <name>   **Date:** <YYYY-MM-DD>
- **Consequence:** low | medium | high  <!-- high = shared systems, data, prod, or hard to undo; triggers mandatory independent review -->

## 1. Outcome — what do you want?

<One or two sentences describing the resulting behaviour, not the steps.
Bad: "improve the deploy pipeline". Good: "a failing test blocks artifact publication".>

## 2. Scope — what is in and out?

- **In scope (may change):** <repos, directories, services, environments>. `factory/work/<slug>/` is always in scope for the report, handoff and review files.
- **Out of scope (must not change):** <paths, APIs, schemas, environments>
- **Context to read first:** <files, docs, tickets, prior handoffs>

## 3. Success evidence — how will "done" be demonstrated?

<!-- Each criterion must be checkable and say what evidence proves it.
     Specific and bounded: "meet these N requirements and document remaining
     limitations", never "make it exceptional". For subjective work, link a
     reference example or a rubric. -->

| # | Criterion | Evidence that proves it |
|---|-----------|-------------------------|
| 1 | <e.g. builds from a clean checkout> | <e.g. `git clean -xfd && make build` exits 0> |
| 2 | | |
| 3 | | |

**Not required:** <polish or extras explicitly not wanted, so the agent knows where to stop>

## 4. Autonomy — what may the agent do without asking?

- **May do freely:** <e.g. edit files in scope, run tests/linters/builds, create a branch, commit locally>
- **Must ask first:** <e.g. push, open a PR, add a dependency, change a public API, touch CI config>
- **Never:** <e.g. deploy, touch prod data, force-push, read secrets>
- **If access is missing:** <e.g. note it as a blocker in the report and continue with everything else>

<!-- Enforced limits belong in .claude/settings.json. This section states intent;
     settings make it stick. If something here is "Never", check settings deny it. -->

## 5. Stop / ask rules — when should the agent stop?

- **Keep going through:** routine failures (timeouts, flaky commands, a failing test you caused). Diagnose and retry with a changed approach.
- **Change approach when:** the same approach has failed twice for the same reason.
- **Stop and ask when:** <e.g. a criterion looks wrong or contradictory, the fix needs out-of-scope changes, a "must ask" action is needed, or 3 distinct approaches have failed>
- **Budget:** <optional: rough time/turn limit, or "none">

## Resources (lead fills in or confirms)

- **Lead:** fable / high   <!-- see docs/model-and-effort.md -->
- **Workers planned:** <none | list of independent workstreams and their agent>
- **Review:** required | optional   <!-- required when Consequence is high -->
