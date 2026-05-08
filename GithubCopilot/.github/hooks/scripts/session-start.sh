#!/usr/bin/env bash
# Session Start Hook
# セッション開始時刻と作業ディレクトリをログに記録
# Copilot Hooks: sessionStart で実行

set -euo pipefail

# stdin から JSON 入力を読む（Copilot Hooks は stdin で渡す）
INPUT=$(cat || true)

# ログディレクトリを作成
mkdir -p logs

# セッション情報をログに追加
{
    echo "════════════════════════════════════════"
    echo "Session started: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Working directory: $(pwd)"
    if [ -n "${INPUT}" ]; then
        echo "Input: ${INPUT}"
    fi
} >> logs/session.log

# Exit 0 でセッション続行を許可
exit 0
