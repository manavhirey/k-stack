# CLAUDE.md

<!-- Last reviewed: 2026-11-19. -->

@factory/FACTORY.md

## This repo

This is the k-stack kit itself: agents, skills, templates and settings that `install.sh` copies into other projects. Changes here change how every installed project works, so treat edits to `.claude/settings.json` deny rules and to absolute rules ("never") as policy changes that need Max's explicit decision.

- Test: `./tests/run.sh` (installs the kit into a temp project and checks the result)
- Keep templates and agent prompts short. Prefer deleting a rule to adding one.
