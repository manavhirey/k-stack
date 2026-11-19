# Report: Robust slugify

- **Brief:** `factory/work/robust-slugify/brief.md`
- **Status:** done with limitations — all criteria pass, but the required independent review has not been run
- **Author:** lead / fable   **Date:** 2026-11-19

## What changed

`slugify()` now returns only `[a-z0-9-]` for any string: accented Latin letters are transliterated, every run of other characters becomes a single `-`, edge dashes are trimmed, and input with nothing sluggable returns `""`.

- `slug.py`: rewritten (stdlib `re` + `unicodedata` only).
- `test_slug.py`: the existing test is kept; 62 cases added.
- Commit `5e01a3a` on branch `robust-slugify`. Not pushed.

## Why

The old implementation only lowercased and replaced spaces, so punctuation, accents and non-ASCII passed straight through.

- **Transliteration:** casefold, NFKD-normalise, drop combining marks. A small table covers Latin letters with no Unicode decomposition (`æ œ ø ł đ ð þ ı`); casefold handles `ß` → `ss`.
- **Non-Latin characters are separators, not deleted:** `"日本語 title"` → `"title"`, and `"a日b"` → `"a-b"` rather than `"ab"`, so words are not silently joined.
- **Apostrophes are treated as punctuation,** per criterion 3 taken literally: `"don't"` → `"don-t"`. The alternative (`"dont"`) was rejected because the brief says punctuation runs become `-`.

## Evidence

All from one run of `python3 -m pytest -q -rA` on commit `5e01a3a`: `63 passed in 0.04s`.

| # | Criterion (from brief) | Result | Evidence |
|---|------------------------|--------|----------|
| 1 | Output contains only `[a-z0-9-]` | pass | `test_output_is_url_safe` — 21 messy inputs (emoji, CJK, Cyrillic, control chars, ligatures, HTML, non-ASCII digits), all PASSED |
| 2 | Accented Latin transliterated | pass | `test_accented_latin_is_transliterated[Crème Brûlée-creme-brulee]` PASSED, plus 5 more cases |
| 3 | Runs collapse to one `-`; no leading/trailing `-` | pass | `test_runs_collapse_and_edges_are_trimmed[  Hello,  World!! -hello-world]` PASSED, plus 6 more; `test_no_leading_trailing_or_repeated_dashes` PASSED on all 21 messy inputs |
| 4 | Empty or all-punctuation returns `""` | pass | `test_empty_or_all_punctuation_returns_empty` — 6 cases PASSED |
| 5 | Existing test still passes | pass | `test_slug.py::test_basic` PASSED; run ended `63 passed`, no failures or errors (exit code not printed separately — the compound command was blocked by permissions) |

## Remaining uncertainty

- Independent review (required by the brief) has not been run.
- Non-string input (`None`, `int`) raises, as before; the brief does not cover it.
- The no-decomposition table is a short list of common letters, not exhaustive; any unmapped letter becomes a separator, so output stays URL-safe either way.
- `.claude/settings.json` lists `git push *` under "ask", while the brief says "never push". Nothing was pushed and settings were not changed.
- `__pycache__/*.pyc` files are tracked in the repo and show as modified after running pytest. They are out of scope and left uncommitted. This report is also uncommitted (outside the brief's commit scope).

## Needed from you

Run `/review robust-slugify`, then `/verify robust-slugify` once any findings are resolved.
