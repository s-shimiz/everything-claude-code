#!/usr/bin/env bash
# Config Protection Hook
# linter/formatter 設定ファイルの改変をブロック
# 元コードを修正させる代わりに設定を緩める「逃げ」を防ぐ
# Copilot Hooks: preToolUse で実行
#
# Exit codes:
#   0 = allow (設定ファイルでない or 検出できなかった)
#   2 = block (設定ファイル改変を検出、エージェントへ説明)

set -euo pipefail

INPUT=$(cat || true)

# 保護対象ファイル名（basename 一致）
PROTECTED_FILES=(
    # ESLint
    ".eslintrc" ".eslintrc.js" ".eslintrc.cjs" ".eslintrc.json"
    ".eslintrc.yml" ".eslintrc.yaml"
    "eslint.config.js" "eslint.config.mjs" "eslint.config.cjs"
    "eslint.config.ts" "eslint.config.mts" "eslint.config.cts"
    # Prettier
    ".prettierrc" ".prettierrc.js" ".prettierrc.cjs" ".prettierrc.json"
    ".prettierrc.yml" ".prettierrc.yaml"
    "prettier.config.js" "prettier.config.cjs" "prettier.config.mjs"
    # Biome
    "biome.json" "biome.jsonc"
    # Ruff
    ".ruff.toml" "ruff.toml"
    # Shell / Style / Markdown
    ".shellcheckrc" ".stylelintrc" ".stylelintrc.json" ".stylelintrc.yml"
    ".markdownlint.json" ".markdownlint.yaml" ".markdownlintrc"
)

# JSON から file_path を抽出（jq があれば使用、なければ簡易抽出）
FILE_PATH=""
if command -v jq >/dev/null 2>&1 && [ -n "$INPUT" ]; then
    FILE_PATH=$(echo "$INPUT" | jq -r '.toolArgs // .tool_input.file_path // .tool_input.file // empty' 2>/dev/null || echo "")
    # toolArgs が JSON 文字列の場合さらに parse
    if [ -n "$FILE_PATH" ] && echo "$FILE_PATH" | jq -e . >/dev/null 2>&1; then
        FILE_PATH=$(echo "$FILE_PATH" | jq -r '.file_path // .file // .path // empty' 2>/dev/null || echo "")
    fi
fi

# ファイルパスが取れなければスキップ
if [ -z "$FILE_PATH" ]; then
    exit 0
fi

BASENAME=$(basename "$FILE_PATH")

# 保護対象かチェック
for protected in "${PROTECTED_FILES[@]}"; do
    if [ "$BASENAME" = "$protected" ]; then
        echo "BLOCKED: Modifying $BASENAME is not allowed." >&2
        echo "Linter/formatter config files protect code quality." >&2
        echo "Fix the source code instead of weakening the config." >&2
        echo "If you genuinely need to update this config, do so manually outside the agent." >&2
        exit 2
    fi
done

exit 0
