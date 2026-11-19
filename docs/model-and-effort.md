# Choosing model and effort

Optimise for the **total cost of a successful result**: model usage across the whole task, plus failed attempts, re-explaining, your supervision and review time, and repairing a wrong implementation. An expensive model that solves a hard problem in one pass can be the cheap option. A cheaper model is right when the task is clear and routine.

**Model choice sets capability. Effort sets thoroughness.**

## Defaults

| Role | Agent | Model | Effort | Why |
|------|-------|-------|--------|-----|
| Everyday interactive work | (main session) | opus | medium | Good capability per cost while you're watching |
| Lead on a long or unattended assignment | `lead` | fable | high | Planning, hard calls, integration and evaluation are where capability pays off; high effort suits long autonomous runs |
| Complex implementation | `implementer` | opus | high | Cross-cutting changes, subtle bugs, behaviour-preserving migrations |
| Bounded implementation | `worker` | sonnet | medium | Exact spec, clear verification |
| Lookups and extraction | `scout` | haiku | low | Read-only; speed matters more than depth |
| Independent review | `reviewer` | fable (opus for low consequence) | high | A stronger, fresh model questions the implementer's assumptions |

`xhigh`/`max` effort: use only where you've measured that it helps on that kind of task. It is not a universal upgrade.

## Where the strongest model earns its cost

- Large changes: migrations, architecture, substantial rewrites.
- Hard 3D, graphics and game-development work.
- Problems that other configurations have already failed on.
- High uncertainty more than high volume: a small concurrency bug can need more capability than a hundred straightforward edits. Examples: an intermittent production defect, preserving behaviour across a language migration, consequences of a change across several services.

## Before escalating, name the failure

| Symptom | Diagnosis | Fix |
|---------|-----------|-----|
| Didn't know about a file, convention, or constraint | Missing context | Add it to the brief or delegation. Same model. |
| Skipped files, didn't run tests, declared success early | Insufficient checking | Raise effort and/or make the verification step explicit. Same model. |
| Read the right evidence carefully and still got it wrong | Beyond capability | Move up a model. |

Higher effort can support persistence. It cannot prove the work is complete; only evidence does.

## Switching models

Each model has its own prompt cache, so switching means the next request re-processes the conversation without cache benefit, and continuity can suffer. Switch at a natural boundary (after a milestone, between build and review) and write a handoff first (`/handoff`). Cache lifetime varies with billing, request type and configuration, so don't plan around a fixed window.

## When to add workers

Add an agent only when you can say exactly what independent work it will complete: a deliverable, owned files, context, and a verification step. Parallel investigation of separate services is a good fit. Two agents editing the same deployment script is not. The lead always verifies the combined result.
