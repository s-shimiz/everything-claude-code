#!/usr/bin/env node
/**
 * GithubCopilot セットアップスクリプト（クロスプラットフォーム）
 *
 * このスクリプトは ECC リポジトリの全スキル / エージェント / コマンドを
 * .github/ 配下に変換コピーします。
 *
 * 使い方:
 *   node setup.js                          # 全 skills を .github/skills/ にコピー
 *   node setup.js --include-all-agents     # + 全 agents を .github/agents/ に変換
 *   node setup.js --include-all-commands   # + 全 commands を .github/prompts/ にコピー
 *   node setup.js --all                    # 上記すべて
 *   node setup.js --force                  # 既存ファイル上書き
 */

'use strict';

const fs = require('fs');
const path = require('path');

const args = process.argv.slice(2);
const FORCE = args.includes('--force');
const ALL = args.includes('--all');
const INCLUDE_ALL_AGENTS = ALL || args.includes('--include-all-agents');
const INCLUDE_ALL_COMMANDS = ALL || args.includes('--include-all-commands');

const SCRIPT_DIR = __dirname;
const ECC_ROOT = path.resolve(SCRIPT_DIR, '..');
const DEST_ROOT = SCRIPT_DIR;

console.log('=== ECC → GitHub Copilot 変換スクリプト ===');
console.log(`ECC Root: ${ECC_ROOT}`);
console.log(`Dest Root: ${DEST_ROOT}`);
console.log('');

// ──────────────────────────────────────────────
// ヘルパー
// ──────────────────────────────────────────────

function ensureDir(p) {
    if (!fs.existsSync(p)) fs.mkdirSync(p, { recursive: true });
}

function copyDirRecursive(src, dest) {
    ensureDir(dest);
    for (const entry of fs.readdirSync(src, { withFileTypes: true })) {
        const s = path.join(src, entry.name);
        const d = path.join(dest, entry.name);
        if (entry.isDirectory()) {
            copyDirRecursive(s, d);
        } else if (entry.isFile()) {
            fs.copyFileSync(s, d);
        }
    }
}

function stripOriginEcc(filePath) {
    if (!fs.existsSync(filePath)) return;
    let content = fs.readFileSync(filePath, 'utf8');
    const cleaned = content.replace(/^origin:\s*ECC\s*\r?\n/m, '');
    if (cleaned !== content) {
        fs.writeFileSync(filePath, cleaned);
    }
}

function convertAgentToolsAndModel(content) {
    // ツール名小文字化
    content = content.replace(/"Read"/g, '"read"');
    content = content.replace(/"Write"/g, '"edit"');
    content = content.replace(/"Edit"/g, '"edit"');
    content = content.replace(/"MultiEdit"/g, '"edit"');
    content = content.replace(/"Grep"/g, '"search"');
    content = content.replace(/"Glob"/g, '"search"');
    content = content.replace(/"Bash"/g, '"shell"');

    // フロントマター内の重複 "edit" / "search" を 1 つに
    content = content.replace(
        /^(tools:\s*\[)([^\]]+)(\])/m,
        (match, p1, p2, p3) => {
            const items = p2.split(',').map(s => s.trim()).filter(Boolean);
            const unique = [...new Set(items)];
            return p1 + unique.join(', ') + p3;
        }
    );

    // model 行を削除
    content = content.replace(/^model:\s*\w+\s*\r?\n/m, '');

    return content;
}

// ──────────────────────────────────────────────
// 1. Skills を .github/skills/ にコピー
// ──────────────────────────────────────────────

function copySkills() {
    const skillsSrc = path.join(ECC_ROOT, 'skills');
    const skillsDst = path.join(DEST_ROOT, '.github', 'skills');

    if (!fs.existsSync(skillsSrc)) {
        console.log('[1/4] skills/ が見つかりません — スキップ');
        return 0;
    }

    console.log('[1/4] Skills を .github/skills/ にコピー中...');
    ensureDir(skillsDst);

    let count = 0;
    for (const entry of fs.readdirSync(skillsSrc, { withFileTypes: true })) {
        if (!entry.isDirectory()) continue;
        const skillSrcDir = path.join(skillsSrc, entry.name);
        const skillDstDir = path.join(skillsDst, entry.name);

        if (fs.existsSync(skillDstDir) && !FORCE) {
            continue;
        }

        copyDirRecursive(skillSrcDir, skillDstDir);

        // SKILL.md から `origin: ECC` 削除
        stripOriginEcc(path.join(skillDstDir, 'SKILL.md'));

        count++;
    }
    console.log(`  → ${count} skills コピー完了`);
    return count;
}

// ──────────────────────────────────────────────
// 2. .agents/skills と .claude/skills もコピー
// ──────────────────────────────────────────────

function copyNativeSkills() {
    const skillsDst = path.join(DEST_ROOT, '.github', 'skills');
    const nativePaths = [
        path.join(ECC_ROOT, '.agents', 'skills'),
        path.join(ECC_ROOT, '.claude', 'skills'),
    ];

    let count = 0;
    for (const src of nativePaths) {
        if (!fs.existsSync(src)) continue;
        const label = path.relative(ECC_ROOT, src);
        console.log(`[2/4] ${label} もコピー中...`);

        for (const entry of fs.readdirSync(src, { withFileTypes: true })) {
            if (!entry.isDirectory()) continue;
            const srcDir = path.join(src, entry.name);
            const dstDir = path.join(skillsDst, entry.name);

            if (fs.existsSync(dstDir) && !FORCE) continue;

            copyDirRecursive(srcDir, dstDir);
            stripOriginEcc(path.join(dstDir, 'SKILL.md'));
            count++;
        }
    }
    if (count > 0) {
        console.log(`  → ${count} ネイティブパススキル追加コピー`);
    }
    return count;
}

// ──────────────────────────────────────────────
// 3. 全 Agents を変換（オプション）
// ──────────────────────────────────────────────

function copyAgents() {
    if (!INCLUDE_ALL_AGENTS) {
        console.log('[3/4] エージェント自動変換スキップ（--include-all-agents で有効化）');
        console.log('       ※ 主要エージェントは既に .github/agents/ に手動変換済み');
        return 0;
    }

    const agentsSrc = path.join(ECC_ROOT, 'agents');
    const agentsDst = path.join(DEST_ROOT, '.github', 'agents');

    if (!fs.existsSync(agentsSrc)) {
        console.log('[3/4] agents/ が見つかりません — スキップ');
        return 0;
    }

    console.log('[3/4] 全エージェントを .github/agents/ に変換コピー中...');
    ensureDir(agentsDst);

    let count = 0;
    for (const entry of fs.readdirSync(agentsSrc, { withFileTypes: true })) {
        if (!entry.isFile() || !entry.name.endsWith('.md')) continue;
        const baseName = entry.name.replace(/\.md$/, '');
        const dstFile = path.join(agentsDst, `${baseName}.agent.md`);

        if (fs.existsSync(dstFile) && !FORCE) continue;

        const content = fs.readFileSync(path.join(agentsSrc, entry.name), 'utf8');
        const converted = convertAgentToolsAndModel(content);
        fs.writeFileSync(dstFile, converted);
        count++;
    }
    console.log(`  → ${count} エージェント変換完了`);
    return count;
}

// ──────────────────────────────────────────────
// 4. 全 Commands を Prompts に変換（オプション）
// ──────────────────────────────────────────────

function copyCommands() {
    if (!INCLUDE_ALL_COMMANDS) {
        console.log('[4/4] コマンド自動変換スキップ（--include-all-commands で有効化）');
        console.log('       ※ 主要コマンドは既に .github/prompts/ に手動変換済み');
        return 0;
    }

    const commandsSrc = path.join(ECC_ROOT, 'commands');
    const promptsDst = path.join(DEST_ROOT, '.github', 'prompts');

    if (!fs.existsSync(commandsSrc)) {
        console.log('[4/4] commands/ が見つかりません — スキップ');
        return 0;
    }

    console.log('[4/4] 全コマンドを .github/prompts/ に変換コピー中...');
    ensureDir(promptsDst);

    let count = 0;
    for (const entry of fs.readdirSync(commandsSrc, { withFileTypes: true })) {
        if (!entry.isFile() || !entry.name.endsWith('.md')) continue;
        const baseName = entry.name.replace(/\.md$/, '');
        const dstFile = path.join(promptsDst, `${baseName}.prompt.md`);

        if (fs.existsSync(dstFile) && !FORCE) continue;

        fs.copyFileSync(path.join(commandsSrc, entry.name), dstFile);
        count++;
    }
    console.log(`  → ${count} コマンド変換完了`);
    return count;
}

// ──────────────────────────────────────────────
// 実行
// ──────────────────────────────────────────────

try {
    const skillCount = copySkills();
    console.log('');
    const nativeCount = copyNativeSkills();
    if (nativeCount > 0) console.log('');
    const agentCount = copyAgents();
    console.log('');
    const cmdCount = copyCommands();
    console.log('');

    console.log('=== 完了 ===');
    console.log('');
    console.log(`Skills: ${skillCount + nativeCount}`);
    console.log(`Agents: ${agentCount} ${INCLUDE_ALL_AGENTS ? '' : '(--include-all-agents 未指定)'}`);
    console.log(`Commands: ${cmdCount} ${INCLUDE_ALL_COMMANDS ? '' : '(--include-all-commands 未指定)'}`);
    console.log('');
    console.log('次のステップ:');
    console.log('  1. .github/ ディレクトリを既存リポジトリに統合');
    console.log('  2. .github/copilot-instructions.md を確認・カスタマイズ');
    console.log('  3. .github/instructions/ の言語別ルールを必要に応じて編集');
    console.log('  4. mcp/mcp.json を VS Code settings.json に統合（必要なら）');
} catch (err) {
    console.error('エラー:', err.message);
    process.exit(1);
}
