---
name: tune-instructions
description: Periodic review of standing instructions (CLAUDE.md, AGENTS.md, agents, skills, settings) for stale, conflicting, or misplaced rules. Proposes changes; never silently weakens a boundary.
---

Review the standing instructions in this repo: `CLAUDE.md`, any `AGENTS.md`, `.claude/agents/*.md`, `.claude/skills/*/SKILL.md`, and `.claude/settings.json`.

For each instruction ask:
1. Does it still solve a real problem? (Look for the workaround it encodes. Is the underlying issue still present?)
2. Is its scope clear: which tasks, files, or situations it applies to?
3. Does it conflict with another instruction, or with what settings actually enforce?
4. Is it a durable convention, or a temporary task detail that belongs in a brief?
5. Does it cause unnecessary work or interruptions, such as over-cautious asks or redundant checks?
6. Is it model-specific advice that may be outdated after an upgrade?

Rules:
- Absolute rules ("never", "must not") may be intentional policy. Do not soften "never X" to "ask before X" without the user's explicit decision. Flag it as a question instead.
- If a rule in CLAUDE.md is meant to be a hard limit, check that settings.json enforces it. If not, propose the settings change.
- Prefer deleting and clarifying over adding.

Output a table: instruction (file:line) | issue | proposed change | needs user decision? Then apply only the changes that need no decision, update the "Last reviewed" date in CLAUDE.md, and list the decisions for the user.
