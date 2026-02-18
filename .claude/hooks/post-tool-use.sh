#!/bin/bash
# Claude Code PostToolUse hook
# Runs typecheck after Write/Edit of .ts/.tsx files
# Feeds errors back to Claude so it can self-correct

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

# Only for TypeScript/TSX files
if [[ "$FILE_PATH" != *.ts && "$FILE_PATH" != *.tsx ]]; then
  exit 0
fi

# Skip config/declaration files (low-value typecheck noise)
if [[ "$FILE_PATH" == *.d.ts || "$FILE_PATH" == */node_modules/* ]]; then
  exit 0
fi

# Debounce: skip if a typecheck ran in the last 15 seconds
LOCKFILE="/tmp/claude-typecheck-lock"
if [ -f "$LOCKFILE" ]; then
  LAST=$(stat -c %Y "$LOCKFILE" 2>/dev/null || echo 0)
  NOW=$(date +%s)
  if (( NOW - LAST < 15 )); then
    exit 0
  fi
fi
touch "$LOCKFILE"

# Find project root
DIR="$CWD"
while [ "$DIR" != "/" ]; do
  if [ -f "$DIR/package.json" ]; then
    PROJECT_ROOT="$DIR"
    break
  fi
  DIR=$(dirname "$DIR")
done

[ -z "$PROJECT_ROOT" ] && exit 0
cd "$PROJECT_ROOT" || exit 0

# Detect typecheck command
if [ -f "pnpm-workspace.yaml" ] || [ -f "pnpm-lock.yaml" ]; then
  if grep -q '"type-check"' package.json 2>/dev/null; then
    CMD="pnpm type-check"
  elif grep -q '"typecheck"' package.json 2>/dev/null; then
    CMD="pnpm typecheck"
  else
    CMD="pnpm exec tsc --noEmit"
  fi
elif grep -q '"type-check"' package.json 2>/dev/null; then
  CMD="npm run type-check"
elif grep -q '"typecheck"' package.json 2>/dev/null; then
  CMD="npm run typecheck"
else
  CMD="npx tsc --noEmit"
fi

# Run with timeout (30s)
RESULT=$(timeout 30 $CMD 2>&1)
EXIT_CODE=$?

# Timeout (exit 124) — skip silently
[ $EXIT_CODE -eq 124 ] && exit 0

# Success — no output needed
[ $EXIT_CODE -eq 0 ] && exit 0

# Errors — feed back to Claude (truncate to 2000 chars)
ERRORS=$(echo "$RESULT" | grep "error TS" | head -20)
[ -z "$ERRORS" ] && ERRORS=$(echo "$RESULT" | tail -20)
ERRORS=$(echo "$ERRORS" | head -c 2000)

# Escape for JSON
ERRORS_JSON=$(echo "$ERRORS" | jq -Rs .)

cat <<ENDJSON
{"decision":"block","reason":$(echo "TypeScript errors after editing $FILE_PATH — fix these before continuing:\n\n$ERRORS" | jq -Rs .)}
ENDJSON

exit 0
