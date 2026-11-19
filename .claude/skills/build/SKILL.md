---
name: build
description: Execute a ready brief as the lead. Plans, delegates only clean independent work to implementer/worker/scout agents, verifies the integrated result, and writes the completion report.
argument-hint: <slug>
---

Execute `factory/work/$ARGUMENTS/brief.md`.

Act as the lead described in `.claude/agents/lead.md`; read it now and follow it. (For a long unattended run, the user should start a dedicated session instead: `claude --agent lead --effort high "Execute factory/work/$ARGUMENTS/brief.md"`. Subagents can't spawn subagents, so the lead must be the main session.)

Checklist:
1. Brief has no blank sections. If it does, stop and run `/brief` on it instead.
2. Plan. Write the plan (and any delegations with owned files) at the top of `factory/work/$ARGUMENTS/handoff.md` so it survives the session.
3. Implement, delegating only where the lead's rules allow.
4. Run every success-evidence check on the integrated result and capture real output.
5. Write `factory/work/$ARGUMENTS/report.md` from `factory/templates/report.md`.
6. If consequence is high or review is required, end by telling the user to run `/factory-review $ARGUMENTS`. Don't call the work done yet.
