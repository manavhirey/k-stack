# Vendored: reviewing-py-code skill

- Source: `reviewing-py-code.zip` supplied by Max on 2026-11-19 (no upstream repository given). Its content is adapted from [refactoring.guru](https://refactoring.guru/design-patterns/python) with PEP 8, PEP 484 and PEP 544 idioms.
- Archive SHA-256: `d10750ffd04f3c21a919f893eadf1e9a2de3716135d2043f52cd4d93530d9146`
- Licence: none included in the archive.

## Local edits

- `SKILL.md` is rewritten. Upstream was a general Clean Code / SOLID / DRY / GoF review with its own per-file report (strengths, issues, before/after refactors, quick wins). Here it is an advisory pass for the `reviewer`: only for diffs touching `.py`, only on changed lines, no refactor or pattern suggestions (they clash with ponytail and the brief's scope), and findings folded into `factory/templates/review.md`. Only Critical items (bugs, security) can affect the verdict.
- `references/` and `examples/` are unchanged, loaded on demand.
- `README.md` is dropped (it described the upstream report format).

It is preloaded into the `reviewer` agent through its `skills:` frontmatter. To update, diff the new archive's `references/` and `examples/` against this folder and re-check the rewritten `SKILL.md` against the new upstream one.
