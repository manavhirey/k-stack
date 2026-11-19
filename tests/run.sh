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
for s in brainstorming systematic-debugging ponytail; do
  [[ -f "$T/fresh/.claude/skills/$s/SKILL.md" && -f "$T/fresh/.claude/skills/$s/LICENSE" ]] || fail "$s skill or licence not installed"
done
! grep -rq "superpowers:" "$KIT/.claude/skills/brainstorming/SKILL.md" "$KIT/.claude/skills/systematic-debugging/SKILL.md" || fail "dangling superpowers: skill reference"
for a in "$KIT"/.claude/agents/*.md; do
  head -8 "$a" | grep -q '^model: ' || fail "$(basename "$a"): no model"
  head -8 "$a" | grep -q '^effort: ' || fail "$(basename "$a"): no effort"
done
echo "PASS: all install smoke tests"
