# e2e dry run: Slugger page

A tiny page (`web/index.html` in the sample project) served on `127.0.0.1:8765`, checked by the e2e instructions with the pinned Chrome DevTools MCP server.

## Run 1: found a real defect

Scenarios 1 and 2 fail; scenario 3 passes. The app is reachable (GET / returned 200).

Both failures have one cause: a script error on page load, so the Make slug button does nothing. The console shows `Uncaught SyntaxError: Invalid regular expression: /[Ì€-Í¯]/g: Range out of order in character class`. That looks like a diacritics-stripping range, probably meant to be `/[\u0300-\u036f]/g`, that got mis-encoded (UTF-8 read as Latin-1). I can't edit application code, so I haven't confirmed the fix.

**1. Slug for 'Crème Brûlée!': fail**
- Steps: navigated to the app, filled Title with `Crème Brûlée!`, clicked Make slug.
- Expected `creme-brulee`. The status region (`uid=1_4 status`) stayed empty after the click and a second snapshot, and the textbox kept its value.
- Console: the SyntaxError above, plus `Failed to load resource: 404` for `/favicon.ico`, which is harmless.
- Screenshot: `<tmp>/s1.png`

**2. Empty title: fail**
- Steps: reloaded the page, clicked Make slug with Title empty.
- Expected 'Enter a title'. The status region (`uid=4_4 status`) stayed empty. The SyntaxError reappeared on reload.
- Screenshot: `<tmp>/s2.png`. I first took this one before clicking, then retook it after the click, so the saved file is the post-click one.

**3. https://example.com blocked: pass**
- Steps: navigated to the URL.
- The tool refused: `Navigation to https://example.com is blocked by blocklist/allowlist rules.` The page stayed on `http://127.0.0.1:8765/`.
- Screenshot: `<tmp>/s3.png`. It shows the app page, since no navigation happened.

**Not checked:** I skipped the Bash step for creating `factory/work/<slug>/evidence/`, since you asked for chrome-devtools tools only. Screenshots are in the scratchpad instead.

## Fix

The page had no `<meta charset>`, so the browser decoded the UTF-8 regex range as Latin-1. Adding `<meta charset=utf-8>` fixed it.

## Run 2: after the fix

Both scenarios pass. Scenario 1's status region showed `creme-brulee` and scenario 2's showed `Enter a title`. After the reload there were no console messages.
