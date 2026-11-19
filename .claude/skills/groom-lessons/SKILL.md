---
name: groom-lessons
description: Trim factory/lessons.md of entries that are no longer true or relevant, using the lessons-groomer agent. Run on demand, or when the lead finds the file over 40 lines.
---

1. If `factory/lessons.md` doesn't exist or is empty, say so and stop.
2. Spawn the `lessons-groomer` agent: "Groom `factory/lessons.md` against the current repository. Follow your rules and return your report."
3. Check its edits stayed in bounds: `git status --porcelain` should show no change outside `factory/lessons.md` that wasn't there before step 2. If one appears, revert it with `git checkout -- <path>` and say so.
4. Show the user the report and `git diff factory/lessons.md`. Leave the change uncommitted for them to accept.
