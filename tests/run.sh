#!/usr/bin/env bash
# Smoke test: install into fresh and pre-existing projects and check results.
set -euo pipefail
KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
fail() { echo "FAIL: $*"; exit 1; }

# 1. Fresh project
mkdir "$T/fresh" && "$KIT/install.sh" "$T/fresh" >/dev/null
for f in CLAUDE.md .claude/settings.json factory/FACTORY.md factory/templates/brief.md \
         factory/templates/report.md factory/templates/handoff.md factory/templates/review.md \
         .claude/agents/lead.md .claude/agents/reviewer.md .claude/skills/brief/SKILL.md .claude/skills/factory-review/SKILL.md docs/model-and-effort.md; do
  [[ -f "$T/fresh/$f" ]] || fail "fresh: missing $f"
done
grep -q '@factory/FACTORY.md' "$T/fresh/CLAUDE.md" || fail "fresh: CLAUDE.md lacks import"

# 2. Existing project: CLAUDE.md and settings.json must not be overwritten
mkdir -p "$T/existing/.claude"
echo "# mine" > "$T/existing/CLAUDE.md"
echo '{"permissions":{}}' > "$T/existing/.claude/settings.json"
out="$("$KIT/install.sh" "$T/existing")"
[[ "$(cat "$T/existing/CLAUDE.md")" == "# mine" ]] || fail "existing: CLAUDE.md overwritten"
[[ "$(cat "$T/existing/.claude/settings.json")" == '{"permissions":{}}' ]] || fail "existing: settings overwritten"
[[ -f "$T/existing/.claude/settings.factory.json" ]] || fail "existing: settings.factory.json not written"
grep -q 'TODO   add this line' <<<"$out" || fail "existing: no CLAUDE.md import hint"

# 3. Re-install without --force must not clobber local edits to kit files
echo "local edit" >> "$T/fresh/.claude/agents/lead.md"
"$KIT/install.sh" "$T/fresh" >/dev/null
grep -q 'local edit' "$T/fresh/.claude/agents/lead.md" || fail "reinstall clobbered local edit"

# 4. Settings JSON is valid and deny rules include force-push and .env
python3 -c "import json,sys; d=json.load(open(sys.argv[1]))['permissions']['deny']; assert 'Bash(git push --force *)' in d and 'Read(./.env)' in d" "$KIT/.claude/settings.json" \
  || fail "settings deny rules missing"

# 5. Agent frontmatter has model + effort
grep -q "^  - ponytail" "$KIT/.claude/agents/implementer.md" || fail "implementer does not preload ponytail"
[[ -f "$T/fresh/.claude/skills/ponytail/SKILL.md" ]] || fail "ponytail skill not installed"
grep -q "^  - systematic-debugging" "$KIT/.claude/agents/implementer.md" || fail "implementer does not preload systematic-debugging"
grep -q "^  - systematic-debugging" "$KIT/.claude/agents/worker.md" || fail "worker does not preload systematic-debugging"
grep -q "^  - py-code-review" "$KIT/.claude/agents/reviewer.md" || fail "reviewer does not preload py-code-review"
[[ -f "$T/fresh/.claude/skills/py-code-review/SKILL.md" && -f "$T/fresh/.claude/skills/py-code-review/references/code-smells.md" ]] || fail "py-code-review not installed"
for f in .claude/skills/brief/SKILL.md .claude/agents/lead.md; do
  for r in $(grep -o "\.claude/skills/py-code-review/[a-z/-]*\.md" "$KIT/$f"); do [[ -f "$T/fresh/$r" ]] || fail "$f references missing $r"; done
done
grep -q '^## Brief gaps' "$KIT/factory/templates/report.md" || fail "report template lacks Brief gaps"
grep -q 'factory/lessons.md' "$KIT/.claude/agents/lead.md" || fail "lead does not log brief gaps"
for a in worker implementer; do grep -q 'Status: blocked' "$KIT/.claude/agents/$a.md" || fail "$a has no blocked path"; done
[[ -f "$T/fresh/.claude/agents/lessons-groomer.md" && -f "$T/fresh/.claude/skills/reflect/SKILL.md" ]] || fail "lessons groomer not installed"
grep -q '^tools: Read, Grep, Glob, Edit$' "$KIT/.claude/agents/lessons-groomer.md" || fail "lessons-groomer tools widened"
for s in brainstorming systematic-debugging ponytail; do
  [[ -f "$T/fresh/.claude/skills/$s/SKILL.md" && -f "$T/fresh/.claude/skills/$s/LICENSE" ]] || fail "$s skill or licence not installed"
done
! grep -rq "superpowers:" "$KIT/.claude/skills/brainstorming/SKILL.md" "$KIT/.claude/skills/systematic-debugging/SKILL.md" || fail "dangling superpowers: skill reference"
# Browser MCP: pinned, locked down, and identical in every agent that declares it
for a in e2e reviewer; do
  f="$KIT/.claude/agents/$a.md"
  for flag in 'chrome-devtools-mcp@1.12.0' -- --headless --isolated --no-usage-statistics --no-performance-crux --no-category-extensions 'allowed-url-pattern=http://localhost'; do
    [[ "$flag" == -- ]] && continue
    grep -qF -- "$flag" "$f" || fail "$a: chrome-devtools missing $flag"
  done
done
[[ "$(sed -n '/^mcpServers:/,/^---/p' "$KIT/.claude/agents/e2e.md")" == "$(sed -n '/^mcpServers:/,/^---/p' "$KIT/.claude/agents/reviewer.md")" ]] || fail "e2e and reviewer chrome-devtools configs differ"
! grep -rq 'chrome-devtools-mcp@latest' "$KIT/.claude" || fail "unpinned chrome-devtools-mcp"
python3 -c "import json,sys; p=json.load(open(sys.argv[1]))['permissions']; assert 'mcp__chrome-devtools__install_extension' in p['deny']" "$KIT/.claude/settings.json" || fail "install_extension not denied"
for a in "$KIT"/.claude/agents/*.md; do
  head -8 "$a" | grep -q '^model: ' || fail "$(basename "$a"): no model"
  head -8 "$a" | grep -q '^effort: ' || fail "$(basename "$a"): no effort"
done
echo "PASS: all install smoke tests"
