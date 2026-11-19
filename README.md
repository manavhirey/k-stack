# k-stack

A portable Claude Code "software factory": define the work, give the agent a way to check its progress, choose its resources on purpose, and have someone independent review the result.

```
/brief → /build (lead) → /factory-review (fresh reviewer) → /factory-verify
   five questions   implement + evidence   evidence-based findings   re-check criteria and fixes
                         ↓ milestones / model switch
                     /handoff
```

## Install

```bash
git clone https://github.com/manavhirey/k-stack
./k-stack/install.sh /path/to/your/project
```

The installer copies the agents, skills, templates and docs. It never overwrites an existing `CLAUDE.md` or `.claude/settings.json`; it tells you what to merge instead. Run `./tests/run.sh` to check the installer.

## Use

| Step | Command | Output |
|------|---------|--------|
| Define the work | `/brief add retry with backoff to the deploy step` | `factory/work/<slug>/brief.md` |
| Build (interactive) | `/build <slug>` | code changes + `report.md` |
| Build (long, unattended) | `claude --agent lead --effort high "Execute factory/work/<slug>/brief.md"` | same |
| Independent review | `/factory-review <slug>`, or a new session: `claude --agent reviewer "Review main...HEAD against factory/work/<slug>/brief.md"` | `review.md` |
| Re-check after fixes | `/factory-verify <slug>` | updated `report.md` |
| Save state | `/handoff <slug>` | `handoff.md` |
| Maintain instructions | `/tune-instructions` (monthly or after a model upgrade) | proposed edits |

Small, obvious fixes don't need a brief. Use the loop for anything you'd want to review.

## What's inside

| Path | Purpose |
|------|---------|
| `factory/templates/brief.md` | Outcome, scope, success evidence, autonomy, stop/ask rules |
| `factory/templates/report.md` | What changed, why, evidence, remaining uncertainty, needed from you |
| `factory/templates/review.md` | Findings labelled demonstrated / likely / speculative |
| `factory/templates/handoff.md` | Goal, decisions, state, checks done, remaining work, blockers |
| `factory/FACTORY.md` | Working agreement, imported into CLAUDE.md with `@factory/FACTORY.md` |
| `.claude/agents/` | `lead` (fable/high), `implementer` (opus/high), `worker` (sonnet/medium), `scout` (haiku/low, read-only), `reviewer` (fable/high, no edit tools) |
| `.claude/skills/` | `brief`, `build`, `factory-review`, `factory-verify`, `handoff`, `tune-instructions` |
| `.claude/settings.json` | allow / ask / deny rules that actually enforce the boundaries |
| `docs/model-and-effort.md` | When to use which model and effort, and how to diagnose before escalating |

## How the lessons map to the kit

| Lesson | Where it lives |
|--------|----------------|
| 1. Pick models economically; diagnose before escalating | `docs/model-and-effort.md`, lead's escalation rule |
| 2. Define "done" first, specific and bounded | brief §3 (criteria + evidence + "not required") |
| 3. Give the strongest model the hard parts | lead on fable; implementer vs worker split |
| 4. Strong lead, smaller workers, only for clean splits | lead's delegation rules; owned files per worker |
| 5. Effort plus persistence and a stopping rule | agent effort settings; brief §5; "change approach after two identical failures" |
| 6. Scope and permissions before a long run | brief §4 + `settings.json` (CLAUDE.md explains, settings enforce) |
| 7. A report that stands on its own | `report.md` template, required from every agent |
| 8. Maintain standing instructions | `/tune-instructions`; "Last reviewed" dates; "never" isn't softened without a decision |
| 9. Switch at boundaries with a handoff | `/handoff`, `handoff.md` |
| Separate implementation from review | `reviewer` gets only the brief and diff, labels evidence, may find nothing |

## Worked example

`examples/robust-slugify/` is a real dry run of the loop on a toy task: the brief, the lead's report (63 tests passing, a brief/settings mismatch flagged), the slug.py diff, and a fresh reviewer's findings (verdict *accept with fixes*, two LIKELY findings, one SPECULATIVE, and an honest "Not reviewed" list).

## Limits to know

- Claude Code ignores a project's `allow` rules until the folder is trusted (`Ignoring N permissions.allow entries … this workspace has not been trusted`). Open the project interactively once and accept the trust dialog. For headless runs (`claude -p`) in CI, containers, or a fresh clone, pass it explicitly: `claude -p --agent lead --settings .claude/settings.json "..."`. Without it, edits and test runs are refused, and a lead correctly stops and reports itself blocked.
- A brief can be stricter than settings (for example, "never push" while settings only *ask* before a push). The lead flags the mismatch; tighten settings if the rule should be enforced.
- The reviewer has no edit tools and only the allowed commands, so it may not be able to run ad-hoc reproductions (it reports those findings as LIKELY, not DEMONSTRATED). Approve its prompts, or allow a scratch command, when you want findings reproduced.
- Subagents can't start subagents. For delegation to work, the lead must be the main session (`--agent lead` or `/build`).
- Bash permission patterns match command prefixes. A determined command can get around them (for example, `cat` with a different path form, or a script). For hard isolation, turn on Claude Code's sandbox or run in a container, and keep real secrets out of the working tree.
- The settings are a starting point. Review the allow list for each project's toolchain, and add its deploy commands to `deny`.
