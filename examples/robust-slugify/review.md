# Review: Robust slugify

- **Brief:** `factory/work/robust-slugify/brief.md`
- **Reviewed:** `main...robust-slugify` (one commit, `5e01a3a`; `slug.py` +30/−1, `test_slug.py` +84)
- **Reviewer:** reviewer / Fable 5.2, fresh context (the untracked implementer `report.md` was not read)
- **Verdict:** accept with fixes

All five criteria are met. The two findings are small transliteration gaps outside the literal criteria, each with a one-line fix; neither was reproduced, because ad-hoc Python is blocked by the project permissions (only `pytest` is allowed).

## Criteria check

| # | Criterion | Independently verified? | Evidence |
|---|-----------|-------------------------|----------|
| 1 | Output contains only `[a-z0-9-]` | yes | Ran `python3 -m pytest -q`: 63 passed, including `test_output_is_url_safe` over 21 messy inputs (emoji, CJK, Cyrillic, control chars, HTML, ligatures). Also holds by construction: the last step at `slug.py:31` replaces every run of `[^a-z0-9]` with `-`, so no other character can survive for any `str`. |
| 2 | Accented Latin transliterated (`"Crème Brûlée"` → `"creme-brulee"`) | yes | `test_accented_latin_is_transliterated` passes with that exact case plus `ÀÉÎÕÜ`, `Señor Ñandú`, `Straße`, `Ærø Łódź`. See F2 for letters it does not cover. |
| 3 | Runs collapse to a single `-`; no leading/trailing `-` | yes | `test_runs_collapse_and_edges_are_trimmed` passes, including `"  Hello,  World!! "` → `"hello-world"`. The invariant test (no leading, trailing or doubled `-`) passes over all messy inputs. The greedy `+` and `.strip("-")` at `slug.py:31` guarantee it. |
| 4 | Empty or all-punctuation input returns `""` | yes | `test_empty_or_all_punctuation_returns_empty` passes for `""`, `"   "`, `"!!!"`, `"---"`, mixed punctuation and `"\t\n"`. |
| 5 | Existing test still passes | yes | `python3 -m pytest -q` → `63 passed in 0.03s`, no failure reported. `test_basic` is unchanged in the diff and passes when run alone (`test_slug.py::test_basic` → 1 passed). |

Scope: the diff touches only `slug.py` and `test_slug.py`. Imports are `re` and `unicodedata` (stdlib) plus `pytest`, which the test run already required. `git grep slugify` finds no callers outside the tests, so no consumer is affected. Nothing was pushed as far as the local repo shows.

## Findings

### F1. Case-folding before NFKD drops letters that only become uppercase after normalisation — LIKELY — low

- **Where:** `slug.py:28`, `unicodedata.normalize("NFKD", text.casefold())`
- **Evidence:** By reading, not reproduced. Some characters have no case mapping but decompose under NFKD to uppercase ASCII, which `[^a-z0-9]+` then removes.
  - Mathematical or "fancy" capitals: `"𝐇𝐞𝐥𝐥𝐨"` → expected `"ello"`.
  - `"№ 5"` → expected `"o-5"`, because `№` decomposes to `No`.
  - `"™"` (`TM`) and `"㎒"` (`MHz` → `hz`) lose their capitals the same way.
- **Impact:** Titles pasted with styled Unicode capitals get mangled slugs. Output stays URL-safe, so no criterion is violated.
- **Suggested fix:** Normalise first, then fold: `unicodedata.normalize("NFKD", text).casefold()`. Add a test such as `"𝐇𝐞𝐥𝐥𝐨"` → `"hello"`. Check that `İ` and `ß` still work in that order.

### F2. Several Latin letters without a decomposition are silently dropped — LIKELY — low

- **Where:** `slug.py:5-14`, the `_NO_DECOMPOSITION` table
- **Evidence:** By reading, not reproduced. The table covers `æ œ ø ł đ ð þ ı`. Letters of the same class that are absent become `-` or vanish: `ħ` (Maltese), `ŧ`, `ŋ`, `ĸ`, `ə`, `ƒ`, `ɨ`, `ƶ`. For example `"Ħamrun"` → expected `"amrun"`, and `"Għaxaq"` → expected `"g-axaq"`.
- **Impact:** Whether this breaks criterion 2 depends on how "accented Latin letters" is read. The brief's own example uses only diacritics, which work. The implementer chose to handle stroke letters such as `ł` and `đ`, so the coverage is inconsistent, not wrong.
- **Suggested fix:** Either add the common ones (`ħ→h`, `ŧ→t`, `ŋ→n`, `ə→e`, `ƒ→f`), or state in the docstring that the table is best-effort. This is the lead's call.

### F3. Different titles can collide, and non-Latin titles become `""` — SPECULATIVE — low

- **Where:** `slug.py:31`
- **Evidence:** `"日本語"` → `""` is asserted by the branch's own test, and the brief permits it explicitly. There are no callers in the repo, so nothing breaks today.
- **Impact:** A future caller that uses the slug as a unique key or URL segment must handle empty and duplicate slugs.
- **Suggested fix:** None required. A docstring note would do.

### Housekeeping (not part of the diff)

- `__pycache__/*.pyc` files are tracked on `main` and show as modified in the working tree after any test run. They are not in the commit, but a later `git add -A` would sweep them in. Untracking them and adding a `.gitignore` is out of scope for this brief and needs the "must ask first" route.

## Not reviewed

- **F1 and F2 outputs.** `python3 -c` required approval, so the expected outputs above come from reading the code and Unicode decomposition rules, not from execution.
- **Exhaustive or fuzz check of criterion 1.** The planned sweep over every code point could not be run. The criterion is still verified by the passing tests and by the structure of the final regex.
- **Byte-level content of test literals.** I could not confirm that `"été"` (commented "already-decomposed input") and `"é combining"` in `test_slug.py` really contain combining characters. If they are precomposed, the decomposed-input path is untested, though the code handles it by construction.
- **Non-`str` input** (`None`, `bytes`). It raises `AttributeError` at `.casefold()`, as the old code did at `.lower()`. The brief sets no requirement.
- **The numeric exit code of pytest.** It was not printed, because `echo $?` was blocked. It is inferred as 0 from "63 passed" and the absence of a tool error.
