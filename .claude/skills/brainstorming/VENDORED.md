# Vendored: brainstorming skill

- Source: https://github.com/obra/superpowers, `skills/brainstorming/`
- Commit: `22f0b463e7a5e579904dd6211a520321035526f7` (2026-11-03)
- Licence: MIT (see `LICENSE`)

Only this skill is vendored, not the superpowers plugin (its other skills, hooks and session-start bootstrap are not used). Edits below point references to other superpowers skills at k-stack's own loop instead. To update, diff upstream against this folder, review, re-apply these edits, and bump the commit.

## Local edits

```diff
--- upstream/brainstorming/SKILL.md	2026-11-19 04:03:11.900746049 +0000
+++ k-stack/brainstorming/SKILL.md	2026-11-19 04:04:20.888154545 +0000
@@ -1,6 +1,6 @@
 ---
 name: brainstorming
-description: "You MUST use this before any creative work - creating features, building components, adding functionality, modifying behavior, or planning anything new, in software or out of it (a talk, a business, a renovation)."
+description: "Use from /brief when a request leaves what is wanted, or why, unclear: draw out intent and approaches before the brief is written. Not for executing an existing brief."
 ---
 
 # Brainstorming
@@ -27,9 +27,9 @@
 
 1. Lay out the approaches in a message of their own, and have your
    human partner pick one (see Lay out the approaches).
-2. Write the design doc, short or full (see Size the Work).
-3. Get their approval of that doc.
-4. Invoke the superpowers:writing-plans skill.
+2. Write the brief, short or full (see Size the Work).
+3. Get their approval of that brief.
+4. Hand it to the lead: suggest `/build <slug>`.
 
 If nothing is open when you write your first message and there's one
 sensible way, steps 1 to 3 happen in that message (see Your First
@@ -242,10 +242,12 @@
 or two each and goes straight to your human partner, without the
 builder check.
 
-**Where it goes:** in a software repo,
-`docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`, committed.
-Otherwise, pick a sensible place and say where. Your human partner's
-preferences override both.
+**Where it goes:** in k-stack the written design *is* the brief:
+`factory/work/<slug>/brief.md`, from `factory/templates/brief.md`.
+Intent goes in Outcome; goals, non-goals and anti-goals in Scope and
+"Not required"; constraints in Scope and Autonomy; approaches in
+"Approaches considered". Success evidence, autonomy and stop rules must
+be filled in too. Your human partner's preferences override this.
 
 **Builder check** (for a project): dispatch a fresh subagent with
 `builder-check-prompt.md` in this directory. When you tell your human
@@ -278,8 +280,8 @@
 stays labeled throwaway, and keeping what it produced is a new request
 that comes back through this gate.
 
-After the design doc is approved, the next step is the plan: invoke
-superpowers:writing-plans and no other skill.
+After the brief is approved, the next step is building it: suggest
+`/build <slug>` and invoke no implementation skill yourself.
 </HARD-GATE>
 
 ## Red Flags
@@ -295,22 +297,5 @@
 
 ## Visual Companion
 
-A browser tab for showing mockups, diagrams, and prototypes. It's a
-tool, not a mode: accepting it doesn't send every question to the
-browser.
-
-**Offer it just-in-time.** Offer it the first time one of the moments
-above comes up, never upfront. The offer is its own message with nothing
-else in it:
-
-> "This might be easier if I show you. Want me to open a browser tab with some mockups?"
-
-If they decline, stay in text and don't offer again unless they raise it.
-
-**Per question, ask: would they understand this better by seeing it?**
-Mockups, layouts, diagrams, and side-by-side designs go in the browser.
-Requirements, scope, tradeoffs, and conceptual choices stay in text. A
-question about a UI topic isn't automatically a visual question.
-
-If they accept, read `visual-companion.md` in this directory before
-starting the server.
+Not vendored into k-stack (it runs a local web server). Sketch in text
+instead: a few lines of what they'd see.
--- upstream/brainstorming/builder-check-prompt.md	2026-11-19 04:03:11.900824273 +0000
+++ k-stack/brainstorming/builder-check-prompt.md	2026-11-19 04:04:02.411890017 +0000
@@ -1,7 +1,7 @@
 # Builder Check Prompt
 
 Dispatch a fresh general-purpose subagent with this prompt once the
-written design exists. Fill in the domain and the document path.
+brief exists (in k-stack the builder is the `lead`). Fill in the domain and the document path.
 
 ```
 You are a talented [DOMAIN, e.g. "software engineer", "event planner",
```
