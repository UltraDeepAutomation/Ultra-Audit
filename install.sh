#!/usr/bin/env sh
# Ultra-Audit installer.
#
# One source of truth: SKILL.md. This script projects it into whatever format
# your agent reads. Nothing is duplicated in the repository.
#
#   ./install.sh <target> [project-dir]
#
# Targets: claude | claude-global | agents | codex | cursor | windsurf |
#          cline | copilot | gemini | print
#
# Default project-dir is the current directory.

set -eu

SRC=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SKILL="$SRC/SKILL.md"
TARGET=${1:-}
DIR=${2:-.}
MARKER="<!-- ultra-audit -->"

[ -f "$SKILL" ] || { echo "SKILL.md not found next to install.sh" >&2; exit 1; }

# SKILL.md minus its YAML frontmatter.
body() {
	awk 'BEGIN { seen = 0; started = 0 }
	     /^---$/ && seen < 2 { seen++; next }
	     seen >= 2 {
	         if (!started) { if ($0 == "") next; started = 1 }
	         print
	     }' "$SKILL"
}

write_file() {
	mkdir -p "$(dirname -- "$1")"
	cat > "$1"
	echo "written: $1"
}

append_section() {
	dest=$1
	mkdir -p "$(dirname -- "$dest")"
	existed=0
	[ -f "$dest" ] && existed=1
	if [ "$existed" = 1 ] && grep -q "$MARKER" "$dest" 2>/dev/null; then
		echo "already present in $dest — remove the '$MARKER' section to reinstall" >&2
		exit 1
	fi
	{
		if [ "$existed" = 1 ]; then printf '\n'; fi
		printf '%s\n\n' "$MARKER"
		body
		printf '\n%s\n' "<!-- /ultra-audit -->"
	} >> "$dest"
	echo "appended: $dest"
}

copy_skill_dir() {
	dest="$1/Ultra-Audit"
	mkdir -p "$dest/reference" "$dest/commands"
	cp "$SKILL" "$dest/SKILL.md"
	cp "$SRC/reference/report-template.md" "$dest/reference/"
	cp "$SRC/commands/ultraaudit.md" "$dest/commands/"
	echo "installed: $dest"
}

case "$TARGET" in
claude)
	copy_skill_dir "$DIR/.claude/skills"
	echo "invoke it by asking for an audit, or copy commands/ultraaudit.md into .claude/commands/"
	;;
claude-global)
	copy_skill_dir "$HOME/.claude/skills"
	;;
agents | codex)
	append_section "$DIR/AGENTS.md"
	echo "the agent reads AGENTS.md automatically; ask it to run the Ultra-Audit procedure"
	;;
gemini)
	append_section "$DIR/GEMINI.md"
	;;
cursor)
	{
		printf -- '---\n'
		printf 'description: Exhaustive bug audit of the codebase followed by autonomous fixing\n'
		printf 'alwaysApply: false\n'
		printf -- '---\n\n'
		body
	} | write_file "$DIR/.cursor/rules/ultra-audit.mdc"
	echo "invoke with: @ultra-audit"
	;;
windsurf)
	body | write_file "$DIR/.windsurf/rules/ultra-audit.md"
	;;
cline)
	body | write_file "$DIR/.clinerules/ultra-audit.md"
	;;
copilot)
	{
		printf -- '---\n'
		printf 'mode: agent\n'
		printf 'description: Exhaustive bug audit of the codebase followed by autonomous fixing\n'
		printf -- '---\n\n'
		body
	} | write_file "$DIR/.github/prompts/ultra-audit.prompt.md"
	echo "invoke with: /ultra-audit"
	;;
print)
	body
	;;
*)
	cat >&2 <<'USAGE'
usage: ./install.sh <target> [project-dir]

  claude         .claude/skills/Ultra-Audit in the project
  claude-global  ~/.claude/skills/Ultra-Audit for every project
  agents, codex  append to AGENTS.md
  gemini         append to GEMINI.md
  cursor         .cursor/rules/ultra-audit.mdc
  windsurf       .windsurf/rules/ultra-audit.md
  cline          .clinerules/ultra-audit.md
  copilot        .github/prompts/ultra-audit.prompt.md
  print          write the procedure to stdout — paste it into any chat

Any agent not listed: ./install.sh print > ultra-audit.md and point it at that file.
USAGE
	exit 2
	;;
esac
