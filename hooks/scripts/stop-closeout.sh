#!/bin/bash
# Stop hook: auto-closeout session to Obsidian
# Fires when Claude session ends. Skips if /closeout was already run this session.

FLAG_FILE="/tmp/claude-obsidian-closeout-flag"

# Check if /closeout already ran this session
if [ -f "$FLAG_FILE" ]; then
  rm -f "$FLAG_FILE"
  exit 0
fi

# Check if obsidian CLI is available
if ! which obsidian &>/dev/null; then
  exit 0
fi

# Find config — walk up from PWD to find .claude/claude-obsidian-thinker.local.md
CONFIG_FILE=""
DIR="$PWD"
while [ "$DIR" != "/" ]; do
  if [ -f "$DIR/.claude/claude-obsidian-thinker.local.md" ]; then
    CONFIG_FILE="$DIR/.claude/claude-obsidian-thinker.local.md"
    break
  fi
  DIR="$(dirname "$DIR")"
done

if [ -z "$CONFIG_FILE" ]; then
  exit 0
fi

# Emit instruction for Claude to silently run closeout
echo "Silently run /closeout now using the obsidian-operator agent. Do not ask the user for confirmation. Do not open any files in Obsidian afterward. Write the session notes quietly in the background."
