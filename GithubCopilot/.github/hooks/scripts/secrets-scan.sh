#!/usr/bin/env bash
# Secrets Scan Hook
# Write/Edit 対象ファイルにハードコードされたシークレットがないかスキャン
# 検出した場合はブロックする
# Copilot Hooks: preToolUse で実行
#
# Exit codes:
#   0 = OK (シークレットなし、または対象でない)
#   2 = block (ハードコードされたシークレット検出)

set -euo pipefail

INPUT=$(cat || true)

# シークレットパターン
# 一般的なプレフィックスや構造を持つトークンを検出
PATTERNS=(
    # AWS
    'AKIA[0-9A-Z]{16}'
    'aws_secret_access_key\s*=\s*[A-Za-z0-9/+=]{40}'
    # GitHub
    'ghp_[A-Za-z0-9]{36}'
    'github_pat_[A-Za-z0-9_]{82}'
    'ghs_[A-Za-z0-9]{36}'
    # OpenAI / Anthropic
    'sk-proj-[A-Za-z0-9]{20,}'
    'sk-ant-[A-Za-z0-9-]{20,}'
    # Slack
    'xox[baprs]-[A-Za-z0-9-]{10,}'
    # Stripe
    'sk_live_[A-Za-z0-9]{24,}'
    'rk_live_[A-Za-z0-9]{24,}'
    # Generic
    'BEGIN (RSA|OPENSSH|EC|DSA|PGP) PRIVATE KEY'
)

# 入力から content / new_content を抽出
CONTENT=""
FILE_PATH=""
if command -v jq >/dev/null 2>&1 && [ -n "$INPUT" ]; then
    # toolArgs を parse して content を取得
    TOOL_ARGS=$(echo "$INPUT" | jq -r '.toolArgs // empty' 2>/dev/null || echo "")
    if [ -n "$TOOL_ARGS" ] && echo "$TOOL_ARGS" | jq -e . >/dev/null 2>&1; then
        CONTENT=$(echo "$TOOL_ARGS" | jq -r '.content // .new_content // .new_string // empty' 2>/dev/null || echo "")
        FILE_PATH=$(echo "$TOOL_ARGS" | jq -r '.file_path // .file // empty' 2>/dev/null || echo "")
    fi
fi

if [ -z "$CONTENT" ]; then
    exit 0
fi

# .env.example / テストファイルは除外
if echo "$FILE_PATH" | grep -E '(\.example$|\.test\.|\.spec\.|/test/|/tests/|/__tests__/|/fixtures/|/__mocks__/)' >/dev/null 2>&1; then
    exit 0
fi

# パターンマッチング
for pattern in "${PATTERNS[@]}"; do
    if echo "$CONTENT" | grep -E "$pattern" >/dev/null 2>&1; then
        {
            echo "BLOCKED: Hardcoded secret detected in $FILE_PATH"
            echo "Pattern matched: $pattern"
            echo ""
            echo "Use environment variables or a secret manager instead:"
            echo "  - process.env.SECRET_NAME (Node.js)"
            echo "  - os.environ['SECRET_NAME'] (Python)"
            echo "  - std::env::var(\"SECRET_NAME\") (Rust)"
            echo ""
            echo "If this is a test fixture or example, place it in test/fixtures/ or *.example file."
        } >&2
        exit 2
    fi
done

exit 0
