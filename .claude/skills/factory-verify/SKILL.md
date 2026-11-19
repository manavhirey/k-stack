---
name: factory-verify
description: Re-check a change after review fixes. Re-runs every success criterion from the brief and confirms each review finding is resolved, with evidence, then updates the report.
argument-hint: <slug>
---

Verify `factory/work/$ARGUMENTS/`.

1. Read `brief.md`, `review.md` and `report.md`.
2. Re-run every check in the brief's success-evidence table on the current code. For browser-checked criteria, start the app locally and spawn the `e2e` agent with the scenarios and pass conditions. Don't reuse earlier output; results may be stale.
3. For each DEMONSTRATED or LIKELY finding in the review, re-run its reproduction (or re-read the cited code) and mark it **resolved**, **not resolved**, or **accepted as limitation** (only if the user said so).
4. Check the fixes didn't widen scope: `git diff --stat` against the reviewed range should touch only expected files.
5. Update `report.md`: refresh the evidence table, add a "Review findings" section with each finding's status, and set Status to done / done with limitations / blocked.
6. Tell the user the result in a few lines. If anything is not resolved, that's the headline.
