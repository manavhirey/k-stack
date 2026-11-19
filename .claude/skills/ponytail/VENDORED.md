# Vendored: ponytail skill

- Source: https://github.com/dietrichgebert/ponytail, `skills/ponytail/SKILL.md`
- Commit: `96608e078b2d5ea607c5c3b8b5a54d1c1fba6846` (2026-10-29), plugin version 5.3.3
- Licence: MIT (see `LICENSE`)
- Changes: none to the ruleset.

Only the skill text is vendored. The plugin's hooks (SessionStart, SubagentStart and UserPromptSubmit Node scripts), its per-turn ledger in `~/.config/ponytail/`, its optional webhook and the auto-updating marketplace install are deliberately not used.

It is preloaded into the `implementer` agent through its `skills:` frontmatter. To update it, diff the upstream file against this one, review the change, and bump the commit above.

Preloading applies when the lead spawns `implementer` as a subagent (checked 2026-11-19). Running `claude --agent implementer` as a main session does not preload it; run `/ponytail` there if you want it.
