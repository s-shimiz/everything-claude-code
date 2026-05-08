#!/usr/bin/env bash
# Post-Edit Format Hook
# ファイル編集後に自動フォーマット（プロジェクトのフォーマッタを検出して実行）
# Copilot Hooks: postToolUse で実行
# 失敗してもセッションは続行（exit 0）

set -euo pipefail

INPUT=$(cat || true)

FILE_PATH=""
if command -v jq >/dev/null 2>&1 && [ -n "$INPUT" ]; then
    TOOL_ARGS=$(echo "$INPUT" | jq -r '.toolArgs // empty' 2>/dev/null || echo "")
    if [ -n "$TOOL_ARGS" ] && echo "$TOOL_ARGS" | jq -e . >/dev/null 2>&1; then
        FILE_PATH=$(echo "$TOOL_ARGS" | jq -r '.file_path // .file // empty' 2>/dev/null || echo "")
    fi
fi

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
    exit 0
fi

# ファイル拡張子で判定
EXT="${FILE_PATH##*.}"
case "$EXT" in
    js|jsx|ts|tsx|mjs|cjs)
        # Prettier または Biome
        if [ -f "biome.json" ] || [ -f "biome.jsonc" ]; then
            command -v npx >/dev/null && npx --no-install biome format --write "$FILE_PATH" 2>/dev/null || true
        elif [ -f ".prettierrc" ] || [ -f ".prettierrc.json" ] || [ -f "prettier.config.js" ]; then
            command -v npx >/dev/null && npx --no-install prettier --write "$FILE_PATH" 2>/dev/null || true
        fi
        ;;
    py)
        # ruff format → black の順
        if command -v ruff >/dev/null 2>&1; then
            ruff format "$FILE_PATH" 2>/dev/null || true
        elif command -v black >/dev/null 2>&1; then
            black --quiet "$FILE_PATH" 2>/dev/null || true
        fi
        ;;
    go)
        command -v gofmt >/dev/null 2>&1 && gofmt -w "$FILE_PATH" 2>/dev/null || true
        ;;
    rs)
        command -v rustfmt >/dev/null 2>&1 && rustfmt "$FILE_PATH" 2>/dev/null || true
        ;;
    java)
        # google-java-format がある場合のみ
        command -v google-java-format >/dev/null 2>&1 && google-java-format -i "$FILE_PATH" 2>/dev/null || true
        ;;
    kt|kts)
        command -v ktlint >/dev/null 2>&1 && ktlint --format "$FILE_PATH" 2>/dev/null || true
        ;;
esac

exit 0
