#!/usr/bin/env bash
# No-Verify Block Hook
# git commit/push --no-verify と同様のフック回避フラグをブロック
# pre-commit/pre-push などの品質ゲートを回避させない
# Copilot Hooks: preToolUse で実行
#
# Exit codes:
#   0 = OK
#   2 = block (--no-verify を検出)

set -euo pipefail

INPUT=$(cat || true)

# bash コマンドを抽出
COMMAND=""
if command -v jq >/dev/null 2>&1 && [ -n "$INPUT" ]; then
    TOOL_ARGS=$(echo "$INPUT" | jq -r '.toolArgs // empty' 2>/dev/null || echo "")
    if [ -n "$TOOL_ARGS" ] && echo "$TOOL_ARGS" | jq -e . >/dev/null 2>&1; then
        COMMAND=$(echo "$TOOL_ARGS" | jq -r '.command // empty' 2>/dev/null || echo "")
    else
        COMMAND="$TOOL_ARGS"
    fi
fi

if [ -z "$COMMAND" ]; then
    exit 0
fi

# git commit/push の --no-verify を検出
if echo "$COMMAND" | grep -E '\bgit\s+(commit|push)\b.*--no-verify\b' >/dev/null 2>&1; then
    {
        echo "BLOCKED: --no-verify flag detected"
        echo "Command: $COMMAND"
        echo ""
        echo "Pre-commit / pre-push hooks exist to enforce quality and security."
        echo "If hooks are failing, fix the underlying issue rather than bypassing them."
    } >&2
    exit 2
fi

# pnpm/npm/yarn の --no-verify-deps なども拒否対象に追加可能
# （プロジェクトポリシーに応じて拡張）

exit 0
