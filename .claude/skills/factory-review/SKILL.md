---
name: factory-review
description: Independent review of a built change. Spawns the reviewer agent in a fresh context with only the brief and the diff, then saves its findings.
argument-hint: <slug> [base-ref]
---

Arguments: $ARGUMENTS (first is the slug; optional second is the base ref, default `main`).

1. Collect only what the reviewer should see:
   - The brief path: `factory/work/<slug>/brief.md`.
   - The diff range: `<base-ref>...HEAD` (confirm with `git diff --stat <base-ref>...HEAD`). Include uncommitted changes if there are any, and say so.
   - Do **not** pass the report, handoff, or your own reasoning about the change. Independence is the point.
2. Spawn the `reviewer` agent with this prompt, filled in:

   > Review the change in `<range>` against the brief at `factory/work/<slug>/brief.md`. Follow your method. You may run tests and commands. Return the review in the format of `factory/templates/review.md`.

   For a low-consequence brief you may pass `model: opus` to save cost; keep the default (fable) for high consequence.
3. Save the reviewer's output verbatim to `factory/work/<slug>/review.md`.
4. Summarise for the user: verdict, demonstrated/likely findings in one line each, and count of speculative ones. Don't argue the findings away. If you believe one is wrong, say what evidence would settle it.
5. If there are findings to fix, the implementer fixes them, then run `/factory-verify <slug>`.

For maximum independence on consequential work, run the review from a brand-new session instead: `claude --agent reviewer "Review <range> against factory/work/<slug>/brief.md"`.
