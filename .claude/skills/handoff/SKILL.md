---
name: handoff
description: Write a handoff doc so work survives a model switch, new session, or compaction. Use at milestones and before changing models.
argument-hint: <slug>
---

Write `factory/work/$ARGUMENTS/handoff.md` from `factory/templates/handoff.md`.

- Fill it from facts, not memory: run `git status`, `git log --oneline -10` and `git diff --stat` for the current state, and list the verification commands actually run with their results.
- Record every decision that a fresh session might otherwise re-litigate, with its rationale.
- "Remaining work" is a numbered list of concrete next steps; the first item must be startable without asking anything.
- Recommend which agent/model/effort the next session should use and why (see `docs/model-and-effort.md`). Switch at a natural boundary, not mid-change.
- Test: could a new session with only the brief and this file continue correctly? If not, add what's missing.

Then tell the user how to resume, e.g. `claude --agent lead "Resume factory/work/$ARGUMENTS from handoff.md"`.
