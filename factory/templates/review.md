# Review: <brief title>

- **Brief:** `factory/work/<slug>/brief.md`
- **Reviewed:** <branch / commit range / diff>
- **Reviewer:** <agent / model / effort>, fresh context
- **Verdict:** accept | accept with fixes | reject

## Criteria check

| # | Criterion | Independently verified? | Evidence |
|---|-----------|-------------------------|----------|
| 1 | | yes / no / could not | <what the reviewer ran or read> |

## Findings

<!-- Ordered by severity. Each finding is one of:
     DEMONSTRATED — reproduced; give exact steps/command and observed output.
     LIKELY — strong evidence (file:line reasoning) but not reproduced.
     SPECULATIVE — a concern worth a look; no evidence of an actual defect.
     Only DEMONSTRATED and LIKELY findings block acceptance.
     "No actionable issues found" is a valid, complete review. -->

### F1. <title> — DEMONSTRATED | LIKELY | SPECULATIVE — high | medium | low

- **Where:** <file:line>
- **Evidence:** <repro steps and output, or reasoning chain>
- **Impact:** <what breaks, for whom>
- **Suggested fix:** <optional>

## Advisory (Python)

<!-- Only when the diff touches .py files (reviewing-py-code skill). One line each:
     path:line — problem — suggested change. Never affects the verdict. Delete if empty. -->

## Not reviewed

<Areas the reviewer could not check and why (no access, no test env, out of time).>
