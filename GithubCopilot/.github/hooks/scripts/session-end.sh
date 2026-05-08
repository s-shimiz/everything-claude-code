#!/usr/bin/env bash
# Session End Hook
# セッション終了時刻を記録
# git の未コミット変更があれば警告
# Copilot Hooks: sessionEnd で実行

set -euo pipefail

mkdir -p logs

{
    echo "Session ended: $(date '+%Y-%m-%d %H:%M:%S')"
} >> logs/session.log

# git の未コミット変更があれば警告（情報のみ、失敗扱いにしない）
if command -v git >/dev/null 2>&1 && [ -d .git ]; then
    UNCOMMITTED=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    if [ "$UNCOMMITTED" -gt 0 ]; then
        {
            echo "[Hook] Reminder: $UNCOMMITTED uncommitted changes remain"
            echo "[Hook] Consider committing before ending the session"
        } >&2
    fi

    # 未プッシュコミットの確認
    if git rev-parse --abbrev-ref @'{u}' >/dev/null 2>&1; then
        UNPUSHED=$(git log --oneline @'{u}'..HEAD 2>/dev/null | wc -l | tr -d ' ')
        if [ "$UNPUSHED" -gt 0 ]; then
            echo "[Hook] Reminder: $UNPUSHED unpushed commits" >&2
        fi
    fi
fi

exit 0
