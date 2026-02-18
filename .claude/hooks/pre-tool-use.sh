#!/bin/bash
# Claude Code PreToolUse hook
# - Auto-approves almost everything silently
# - Only asks for genuinely destructive operations
# - Enter = Yes in the dialog

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name')

ALLOW='{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}'
DENY='{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Denied via dialog"}}'

# Read-only tools: no permission needed, pass through
case "$TOOL_NAME" in
  Read|Glob|Grep|WebFetch|WebSearch|ListMcpResourcesTool|ToolSearch|ExitPlanMode|AskUserQuestion)
    exit 0
    ;;
esac

# Bash: auto-approve safe commands, only ask for destructive ones
if [ "$TOOL_NAME" = "Bash" ]; then
  COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

  DANGEROUS_PATTERN='(rm\s+-[rRfF]{1,3}\b|git\s+(push\s+[^|&;]*(-f|--force)|reset\s+--hard|clean\s+-[fdxX])|DROP\s+(TABLE|DATABASE|SCHEMA)|TRUNCATE\s+TABLE|dd\s+if=|mkfs\b|:\(\)\{.*\}|chmod\s+-R\s+777)'

  if echo "$COMMAND" | grep -qEi "$DANGEROUS_PATTERN"; then
    DETAIL=$(echo "$COMMAND" | head -c 400)
    DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus \
      paplay /usr/share/sounds/freedesktop/stereo/message-new-instant.oga &
    DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus \
      kdialog \
        --title "Claude Code" \
        --icon dialog-question \
        --yesno "<b>Bash</b><br><br><tt>$(echo "$DETAIL" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')</tt>" \
        --yes-label "Allow" \
        --no-label "Deny" 2>/dev/null
    [ $? -eq 0 ] && echo "$ALLOW" || echo "$DENY"
    exit 0
  fi

  echo "$ALLOW"
  exit 0
fi

# Write, Edit, Task, and everything else: auto-approve
echo "$ALLOW"
exit 0
