# Vendored: systematic-debugging skill

- Source: https://github.com/obra/superpowers, `skills/systematic-debugging/`
- Commit: `22f0b463e7a5e579904dd6211a520321035526f7` (2026-11-03)
- Licence: MIT (see `LICENSE`)

Only this skill is vendored, not the superpowers plugin (its other skills, hooks and session-start bootstrap are not used). Edits below point references to other superpowers skills at k-stack's own loop instead. To update, diff upstream against this folder, review, re-apply these edits, and bump the commit.

## Local edits

```diff
--- upstream/systematic-debugging/SKILL.md	2026-11-19 04:03:11.902251323 +0000
+++ k-stack/systematic-debugging/SKILL.md	2026-11-19 04:04:02.411823998 +0000
@@ -174,7 +174,7 @@
    - Automated test if possible
    - One-off test script if no framework
    - MUST have before fixing
-   - Use the `superpowers:test-driven-development` skill for writing proper failing tests
+   - Write it so it fails for the reason you identified, and watch it fail before fixing
 
 2. **Implement Single Fix**
    - Address the root cause identified
@@ -186,7 +186,7 @@
    - Test passes now?
    - No other tests broken?
    - Issue actually resolved?
-   - Use the `superpowers:verification-before-completion` skill before claiming success
+   - Run the brief's success-evidence checks and quote real output before claiming success
 
 4. **If Fix Doesn't Work**
    - STOP
```
