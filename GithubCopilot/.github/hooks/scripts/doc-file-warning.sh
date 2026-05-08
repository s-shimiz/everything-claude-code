#!/usr/bin/env bash
# Doc File Warning Hook
# 構造化されていない場所への ad-hoc ドキュメントファイル作成を警告
# 警告のみ（exit 0）— ブロックはしない
# Copilot Hooks: preToolUse で実行

set -euo pipefail

INPUT=$(cat || true)

# ad-hoc ファイル名パターン（大文字のみ）
ADHOC_PATTERN='^(NOTES|TODO|SCRATCH|TEMP|DRAFT|BRAINSTORM|SPIKE|DEBUG|WIP)\.(md|txt)$'

# 構造化ディレクトリ（このパス内では ad-hoc 名でも OK）
STRUCTURED_DIRS='(^|/)(docs|\.claude|\.github|commands|skills|benchmarks|templates|\.history|memory)/'

# JSON から file_path を抽出
FILE_PATH=""
if command -v jq >/dev/null 2>&1 && [ -n "$INPUT" ]; then
    FILE_PATH=$(echo "$INPUT" | jq -r '.toolArgs // .tool_input.file_path // empty' 2>/dev/null || echo "")
    if [ -n "$FILE_PATH" ] && echo "$FILE_PATH" | jq -e . >/dev/null 2>&1; then
        FILE_PATH=$(echo "$FILE_PATH" | jq -r '.file_path // .file // .path // empty' 2>/dev/null || echo "")
    fi
fi

if [ -z "$FILE_PATH" ]; then
    exit 0
fi

# パスを正規化
NORMALIZED=$(echo "$FILE_PATH" | tr '\\' '/')
BASENAME=$(basename "$NORMALIZED")

# 構造化ディレクトリ内なら OK
if echo "$NORMALIZED" | grep -E "$STRUCTURED_DIRS" >/dev/null 2>&1; then
    exit 0
fi

# ad-hoc 名にマッチするか
if echo "$BASENAME" | grep -E "$ADHOC_PATTERN" >/dev/null 2>&1; then
    {
        echo "[Hook] WARNING: Ad-hoc documentation filename detected"
        echo "[Hook] File: $FILE_PATH"
        echo "[Hook] Consider using a structured path (e.g. docs/, .github/, skills/, benchmarks/, templates/)"
    } >&2
fi

# 警告のみ — 必ず 0 で終了
exit 0
