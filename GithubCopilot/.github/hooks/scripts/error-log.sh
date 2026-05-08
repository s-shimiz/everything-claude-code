#!/usr/bin/env bash
# Error Log Hook
# エージェント実行中のエラーをログに記録
# Copilot Hooks: errorOccurred で実行

set -euo pipefail

INPUT=$(cat || true)

mkdir -p logs

{
    echo "═══ Error: $(date '+%Y-%m-%d %H:%M:%S') ═══"
    if [ -n "$INPUT" ]; then
        echo "$INPUT"
    fi
    echo ""
} >> logs/errors.log

exit 0
