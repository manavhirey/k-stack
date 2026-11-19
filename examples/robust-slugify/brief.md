# Brief: Robust slugify

- **Slug:** robust-slugify
- **Requested by:** Max   **Date:** 2026-11-19
- **Consequence:** medium

## 1. Outcome
`slugify()` produces URL-safe slugs from arbitrary user titles.

## 2. Scope
- **In scope:** `slug.py`, `test_slug.py`
- **Out of scope:** everything else; no new dependencies (stdlib only)
- **Context to read first:** `slug.py`, `test_slug.py`

## 3. Success evidence
| # | Criterion | Evidence |
|---|-----------|----------|
| 1 | Output contains only `[a-z0-9-]` | test over a list of messy inputs |
| 2 | Accented Latin letters are transliterated (`"Crème Brûlée"` → `"creme-brulee"`) | unit test |
| 3 | Runs of spaces/punctuation collapse to a single `-`; no leading/trailing `-` | unit tests incl. `"  Hello,  World!! "` → `"hello-world"` |
| 4 | Empty or all-punctuation input returns `""` | unit test |
| 5 | Existing test still passes | `python3 -m pytest -q` exits 0 |

**Not required:** non-Latin transliteration (e.g. CJK may become `""`), max length.

## 4. Autonomy
- **May do freely:** edit in-scope files, run pytest, commit on a branch `robust-slugify`
- **Must ask first:** anything else
- **Never:** push
- **If access is missing:** note it in the report

## 5. Stop / ask rules
- Keep going through test failures. Change approach after the same failure twice.
- Stop and ask if a criterion is contradictory.

## Resources
- **Lead:** fable / high (dry run; normally a task this small is a single opus/sonnet session)
- **Workers planned:** none
- **Review:** required
