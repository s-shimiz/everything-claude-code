#!/usr/bin/env bash
# GithubCopilot セットアップスクリプト（macOS / Linux）
#
# このスクリプトは ECC リポジトリのスキル / エージェント / コマンドを
# .github/ 配下に一括変換コピーします。

set -euo pipefail

ECC_ROOT="${ECC_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
DEST_ROOT="${DEST_ROOT:-$(cd "$(dirname "$0")" && pwd)}"
INCLUDE_ALL_AGENTS=false
INCLUDE_ALL_COMMANDS=false
FORCE=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --include-all-agents) INCLUDE_ALL_AGENTS=true; shift ;;
        --include-all-commands) INCLUDE_ALL_COMMANDS=true; shift ;;
        --force) FORCE=true; shift ;;
        --ecc-root) ECC_ROOT="$2"; shift 2 ;;
        --dest-root) DEST_ROOT="$2"; shift 2 ;;
        *) echo "不明な引数: $1"; exit 1 ;;
    esac
done

echo "=== ECC → GitHub Copilot 変換スクリプト ==="
echo "ECC Root: $ECC_ROOT"
echo "Dest Root: $DEST_ROOT"
echo ""

# ──────────────────────────────────────────────
# 1. Skills を .github/skills/ にコピー
# ──────────────────────────────────────────────

SKILLS_SRC="$ECC_ROOT/skills"
SKILLS_DST="$DEST_ROOT/.github/skills"

if [ -d "$SKILLS_SRC" ]; then
    echo "[1/4] Skills を .github/skills/ にコピー中..."
    mkdir -p "$SKILLS_DST"

    skill_count=0
    for skill_dir in "$SKILLS_SRC"/*/; do
        [ -d "$skill_dir" ] || continue
        skill_name=$(basename "$skill_dir")
        dest_dir="$SKILLS_DST/$skill_name"

        if [ -d "$dest_dir" ] && [ "$FORCE" = false ]; then
            continue
        fi

        cp -R "$skill_dir" "$dest_dir"

        # SKILL.md から `origin: ECC` 行を削除
        skill_file="$dest_dir/SKILL.md"
        if [ -f "$skill_file" ]; then
            sed -i.bak '/^origin:\s*ECC\s*$/d' "$skill_file" && rm -f "$skill_file.bak"
        fi

        skill_count=$((skill_count + 1))
    done
    echo "  → $skill_count skills コピー完了"
else
    echo "[1/4] skills/ ディレクトリが見つかりません — スキップ"
fi
echo ""

# ──────────────────────────────────────────────
# 2. .agents/skills と .claude/skills もコピー
# ──────────────────────────────────────────────

for native_path in ".agents/skills" ".claude/skills"; do
    src="$ECC_ROOT/$native_path"
    if [ -d "$src" ]; then
        echo "[2/4] $native_path もコピー中..."
        for skill_dir in "$src"/*/; do
            [ -d "$skill_dir" ] || continue
            skill_name=$(basename "$skill_dir")
            dest_dir="$SKILLS_DST/$skill_name"
            if [ ! -d "$dest_dir" ] || [ "$FORCE" = true ]; then
                cp -R "$skill_dir" "$dest_dir"
                echo "  - $skill_name ($native_path より)"
            fi
        done
    fi
done
echo ""

# ──────────────────────────────────────────────
# 3. 全 Agents を変換（オプション）
# ──────────────────────────────────────────────

if [ "$INCLUDE_ALL_AGENTS" = true ]; then
    echo "[3/4] 全エージェントを .github/agents/ に変換コピー中..."

    AGENTS_SRC="$ECC_ROOT/agents"
    AGENTS_DST="$DEST_ROOT/.github/agents"
    mkdir -p "$AGENTS_DST"

    agent_count=0
    for agent_file in "$AGENTS_SRC"/*.md; do
        [ -f "$agent_file" ] || continue
        agent_name=$(basename "$agent_file" .md)
        dest_file="$AGENTS_DST/$agent_name.agent.md"

        if [ -f "$dest_file" ] && [ "$FORCE" = false ]; then
            continue
        fi

        # ツール名と model 行を変換
        sed -E '
            s/"Read"/"read"/g;
            s/"Write"/"edit"/g;
            s/"Edit"/"edit"/g;
            s/"MultiEdit"/"edit"/g;
            s/"Grep"/"search"/g;
            s/"Glob"/"search"/g;
            s/"Bash"/"shell"/g;
            /^model:[[:space:]]*[a-z]+[[:space:]]*$/d;
        ' "$agent_file" > "$dest_file"

        agent_count=$((agent_count + 1))
    done
    echo "  → $agent_count エージェント変換完了"
else
    echo "[3/4] エージェント自動変換スキップ（--include-all-agents で有効化）"
fi
echo ""

# ──────────────────────────────────────────────
# 4. 全 Commands を Prompts に変換（オプション）
# ──────────────────────────────────────────────

if [ "$INCLUDE_ALL_COMMANDS" = true ]; then
    echo "[4/4] 全コマンドを .github/prompts/ に変換コピー中..."

    COMMANDS_SRC="$ECC_ROOT/commands"
    PROMPTS_DST="$DEST_ROOT/.github/prompts"
    mkdir -p "$PROMPTS_DST"

    cmd_count=0
    for cmd_file in "$COMMANDS_SRC"/*.md; do
        [ -f "$cmd_file" ] || continue
        cmd_name=$(basename "$cmd_file" .md)
        dest_file="$PROMPTS_DST/$cmd_name.prompt.md"

        if [ -f "$dest_file" ] && [ "$FORCE" = false ]; then
            continue
        fi

        cp "$cmd_file" "$dest_file"
        cmd_count=$((cmd_count + 1))
    done
    echo "  → $cmd_count コマンド変換完了"
else
    echo "[4/4] コマンド自動変換スキップ（--include-all-commands で有効化）"
fi
echo ""

echo "=== 完了 ==="
echo ""
echo "次のステップ:"
echo "  1. .github/ ディレクトリを既存リポジトリに統合"
echo "  2. .github/copilot-instructions.md を確認・カスタマイズ"
echo "  3. .github/instructions/ の言語別ルールを必要に応じて編集"
echo "  4. mcp/mcp.json を VS Code settings.json に統合（必要なら）"
echo ""
echo "オプション:"
echo "  --include-all-agents   全 48 エージェントを自動変換"
echo "  --include-all-commands 全 68 コマンドを自動変換"
echo "  --force                既存ファイルを上書き"
