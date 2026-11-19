---
name: brief
description: Draft a five-question task brief (outcome, scope, success evidence, autonomy, stop/ask) for a substantial assignment, asking the user only for what is missing.
argument-hint: <what you want done>
---

Turn the user's request into a brief at `factory/work/<slug>/brief.md`, using `factory/templates/brief.md`.

Request: $ARGUMENTS

1. Pick a short kebab-case slug. Create `factory/work/<slug>/`.
2. Investigate before asking: read the relevant code, existing tests, CI config and docs so you can propose concrete scope and checkable criteria yourself. Use the `scout` agent for broad lookups.
3. If the request leaves *what* is wanted, or *why*, unclear, run the conversation with the `brainstorming` skill first (one question at a time, approaches laid out, your calls stated). Its written design is this brief. If everything that matters is already in the request, skip it.
4. Draft all five sections. For **success evidence**, write criteria a machine or a person can check, each with the exact command or observation that proves it. Prefer 3–7 criteria. Add a "Not required" line so there is a clear stopping point. For subjective work, ask for or point to a reference example or rubric.
5. Set **consequence**. Mark it high if the change touches shared systems, CI/CD used by others, data, production, security, or anything hard to undo. High consequence means review is required.
6. Check autonomy against `.claude/settings.json`. If the brief wants something denied that settings allow (or the reverse), point it out.
7. Builder check (for anything beyond a small change): dispatch a fresh subagent with `.claude/skills/brainstorming/builder-check-prompt.md`, the builder being the `lead`. Settle what it raises that you can; carry the rest to step 8.
8. Show the user the draft and ask only about what you could not determine or what is genuinely their call: usually the outcome's intent, autonomy limits, and stop rules. Batch the questions into one message.
9. Update the brief with their answers. The brief is ready when no section is blank. Then suggest: `claude --agent lead "Execute factory/work/<slug>/brief.md"` or `/build <slug>`.
