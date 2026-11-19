---
name: reviewing-py-code
description: Advisory Python code-quality pass for the reviewer. Use during a review when the diff touches .py files; adds Clean Code, DRY and code-smell notes on the changed lines only, without affecting the verdict except for bugs or security issues.
---

# Python review (advisory)

An extra pass for reviews whose diff touches `.py` files. If it touches none, skip this skill.

## Scope

- Only lines the diff adds or changes, plus what they call directly when needed to judge them. Untouched code is out of scope even if it is poor.
- Don't suggest refactors, function splits, new abstractions or design patterns. The brief sets scope and the implementer works to the smallest change; a review that pushes restructuring fights both.
- If the brief's "Approaches considered" records a design pattern, check the change follows it; don't reopen the choice.
- Do flag the reverse: abstraction, indirection or generality the change added that the brief doesn't need (Speculative Generality, Lazy Class, Middle Man).

## What to look for in the changed lines

- **Bugs and security** (Critical): mutable default arguments, bare `except:` or swallowed exceptions, wrong exception types, injection, unsafe deserialisation, resource leaks, class-level mutable state shared by accident.
- **Clarity**: misleading names, magic numbers, comments that say *what* instead of *why*, missing type hints on new public functions.
- **DRY**: duplication the change introduced (not duplication it sits next to).
- **Smells** the change introduced, using `references/code-smells.md` when unsure what something is called or why it matters.

Load `references/` and `examples/` only when you need them to name or explain a specific issue. Most reviews need none.

## Reporting

Fold results into the normal review (`factory/templates/review.md`). No separate per-file report, strengths, quick wins or before/after blocks.

- **Critical** (bug, security, data corruption): report as an ordinary finding with its DEMONSTRATED / LIKELY / SPECULATIVE label. Only these can affect the verdict, by the usual rule.
- **Everything else**: one line each under **Advisory (Python)**, as `path:line — problem — suggested change`, at most a sentence. These never change the verdict. Omit the section when there is nothing worth saying.
