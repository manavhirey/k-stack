#!/usr/bin/env bash
# Install the k-stack factory kit into a target project.
#   ./install.sh /path/to/project          # install, never overwrite
#   ./install.sh /path/to/project --force  # overwrite kit-owned files (agents, skills, templates, FACTORY.md)
#
# Never overwrites the target's CLAUDE.md or .claude/settings.json. If either
# exists, it prints what to merge instead.
set -euo pipefail

KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:?usage: install.sh /path/to/project [--force]}"
FORCE="${2:-}"
TARGET="$(cd "$TARGET" && pwd)"

copy() { # src dst
  local src="$1" dst="$2"
  if [[ -e "$dst" && "$FORCE" != "--force" ]]; then
    echo "skip   ${dst#$TARGET/} (exists; use --force to replace)"
  else
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    echo "wrote  ${dst#$TARGET/}"
  fi
}

# Kit-owned files
while IFS= read -r -d '' f; do
  rel="${f#$KIT/}"
  copy "$f" "$TARGET/$rel"
done < <(find "$KIT/.claude/agents" "$KIT/.claude/skills" "$KIT/factory/templates" "$KIT/docs" -type f -print0)
copy "$KIT/factory/FACTORY.md" "$TARGET/factory/FACTORY.md"
mkdir -p "$TARGET/factory/work"
touch "$TARGET/factory/work/.gitkeep"

# CLAUDE.md: create from template, or tell the user how to import.
if [[ -e "$TARGET/CLAUDE.md" ]]; then
  if grep -q '@factory/FACTORY.md' "$TARGET/CLAUDE.md"; then
    echo "ok     CLAUDE.md already imports factory/FACTORY.md"
  else
    echo "TODO   add this line near the top of CLAUDE.md:  @factory/FACTORY.md"
  fi
else
  cp "$KIT/factory/templates/CLAUDE.md" "$TARGET/CLAUDE.md"
  echo "wrote  CLAUDE.md (fill in Project conventions)"
fi

# settings.json: never overwrite; boundaries are policy.
if [[ -e "$TARGET/.claude/settings.json" ]]; then
  cp "$KIT/.claude/settings.json" "$TARGET/.claude/settings.factory.json"
  echo "TODO   .claude/settings.json exists. Merge rules from .claude/settings.factory.json by hand, then delete it."
else
  cp "$KIT/.claude/settings.json" "$TARGET/.claude/settings.json"
  echo "wrote  .claude/settings.json (review allow/ask/deny for this project)"
fi

echo
echo "Next: fill in CLAUDE.md conventions, review .claude/settings.json, then try:  /brief <what you want done>"
