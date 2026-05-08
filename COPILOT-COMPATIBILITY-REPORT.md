# Everything Claude Code (ECC) — GitHub Copilot 互換性レポート

> **リポジトリ**: [affaan-m/everything-claude-code](https://github.com/affaan-m/everything-claude-code)
> **調査日**: 2026-05-08（**改訂版** — Copilot カスタムエージェント / スキル仕様判明後の再評価）
> **対象**: GitHub Copilot CLI / VS Code GitHub Copilot Chat / Copilot クラウドエージェント

---

## サマリー（重要な改訂）

> **当初の評価を大幅に修正しました。**
>
> GitHub Copilot は **`.claude/skills/` および `.agents/skills/` ディレクトリをネイティブに認識** し、さらに **カスタムエージェント** および **カスタムスキル** の仕様が ECC の SKILL.md / agent 定義と**ほぼ同一**です。
> したがって ECC の知識資産の **大部分が、フロントマターの軽微な調整のみでそのまま流用可能** です。

### GitHub Copilot のネイティブ機能との対応

| GitHub Copilot 機能 | ECC で対応するもの | 互換性 |
|---|---|---|
| **カスタムスキル** (`SKILL.md`) | `skills/*/SKILL.md` | ✅ ほぼそのまま（`origin: ECC` 行削除のみ） |
| **カスタムエージェント** (`*.agent.md`) | `agents/*.md` | ✅ フロントマター軽微な変換のみ |
| **インストラクション** (`.instructions.md`) | `rules/**/*.md` | ✅ `applyTo` を追加するだけ |
| **プロンプトファイル** (`.prompt.md`) | `commands/*.md` | ✅ description フロントマターのみ |
| **リポジトリ指示** (`copilot-instructions.md`) | `SOUL.md`, `RULES.md`, `AGENTS.md`, `CLAUDE.md` | ✅ そのまま転記可（哲学・規約の最高品質素材） |
| **MCP サーバー** | `mcp-configs/mcp-servers.json` | ✅ そのまま流用可 |

### 互換性の分類（改訂）

| 分類 | 意味 |
|------|------|
| ✅ **ネイティブ互換** | パスを合わせるだけ、もしくは無変換で Copilot が自動認識 |
| 🟢 **軽微な変換で使用可** | フロントマター数行の修正のみで動作（本文は無変更） |
| ❌ **使用不可** | Claude Code 専用機能であり、Copilot では機能しない |

---

## 1. ✅ ネイティブ互換 — Skills（最重要発見）

### GitHub Copilot は `.claude/skills/` と `.agents/skills/` をネイティブ認識

GitHub 公式ドキュメント（[エージェント スキルの追加](https://docs.github.com/ja/copilot/how-tos/copilot-on-github/customize-copilot/customize-cloud-agent/add-skills)）より、Copilot は以下のディレクトリを**プロジェクトスキル**として自動認識します：

- `.github/skills/`
- **`.claude/skills/`** ← ECC が既に使用
- **`.agents/skills/`** ← ECC が既に使用
- `~/.copilot/skills/`（個人スキル）
- `~/.agents/skills/`（個人スキル）

### ECC のスキル配置と Copilot の認識

ECC リポジトリには 3 か所にスキルが存在します：

| ECC のスキル配置 | ファイル数 | Copilot 認識 |
|------|---------|-------------|
| `skills/` | 182 件 | ❌（パス非標準）→ `.agents/skills/` などへコピー必要 |
| `.agents/skills/` | 32 件 | ✅ **ネイティブ認識** |
| `.claude/skills/everything-claude-code/` | 1 件 | ✅ **ネイティブ認識** |

### スキル定義フォーマットの比較

**Copilot のスキル仕様:**
```yaml
---
name: skill-name           # 必須（小文字 + ハイフン）
description: いつ使うか     # 必須
license: MIT               # 任意
allowed-tools: shell        # 任意（スクリプト実行時）
---

Markdown 本文（指示・例・ガイドライン）
```

**ECC のスキル例（`skills/api-design/SKILL.md`）:**
```yaml
---
name: api-design
description: REST API design patterns including resource naming, status codes...
origin: ECC                # ← この行のみ Copilot 仕様外
---

# API Design Patterns
（本文はそのまま使える）
```

### 変換手順（Skills）

ECC スキルを Copilot で使うには：

1. スキルディレクトリ（`SKILL.md` を含むフォルダ）を `.github/skills/` または `.agents/skills/` または `~/.copilot/skills/` にコピー
2. フロントマターから `origin: ECC` 行を削除
3. **完了** — Copilot が自動認識

または、`gh skill` CLI でパッケージ管理：

```bash
gh skill install OWNER/REPO SKILL_NAME
```

---

## 2. 🟢 軽微な変換で使用可 — Custom Agents

### Copilot のカスタムエージェント仕様

GitHub 公式ドキュメント（[カスタム エージェントの作成](https://docs.github.com/ja/copilot/how-tos/copilot-on-github/customize-copilot/customize-cloud-agent/create-custom-agents)）より：

**配置パス:** `.github/agents/<name>.agent.md`

**フォーマット:**
```yaml
---
name: agent-name            # 任意（省略時はファイル名）
description: 用途説明        # 必須
tools: ["read", "edit", "search", "some-mcp-server/tool-1"]  # 任意
mcp-servers:                # 任意（このエージェント専用 MCP）
  - name: server-name
    ...
model: モデル名              # 任意（VS Code/JetBrains/Eclipse/Xcode で有効）
target: vscode | github-copilot  # 任意
---

エージェントのプロンプト（最大 30,000 文字）
```

### ECC のエージェントとの差分

**ECC の `agents/code-reviewer.md`:**
```yaml
---
name: code-reviewer
description: Expert code review specialist...
tools: ["Read", "Grep", "Glob", "Bash"]
model: sonnet
---
```

**Copilot 互換に変換 → `.github/agents/code-reviewer.agent.md`:**
```yaml
---
name: code-reviewer
description: Expert code review specialist...
tools: ["read", "search", "edit"]   # 小文字 + Copilot ツール名
# model 行を削除（または Copilot のモデル名に変更）
---
```

### 変換手順（Agents）

ECC の 48 エージェントを Copilot で使うには：

1. ファイルを `.github/agents/` に配置し、ファイル名を `<name>.agent.md` に変更
2. フロントマターのツール名を Copilot 仕様に変換：
   - `Read` → `read`
   - `Grep` / `Glob` → `search`
   - `Write` / `Edit` → `edit`
   - `Bash` → `shell`（注: 事前承認は慎重に）
3. `model: sonnet` / `model: opus` 行を削除、または Copilot のモデル名に置き換え
4. 本文は**そのまま**（最大 30,000 文字以内に収める）

---

## 3. 🟢 軽微な変換で使用可 — Rules → `.instructions.md`

## 3. 🟢 軽微な変換で使用可 — Rules → `.instructions.md`

### Copilot のインストラクションファイル仕様

`.github/instructions/` ディレクトリに `.instructions.md` ファイルを**複数配置可能**。`applyTo` でファイルパターンごとに自動適用されます。

### ECC の Rules マッピング

| ECC のファイル | → Copilot instructions ファイル | applyTo |
|---|---|---|
| `rules/common/coding-style.md` | `.github/instructions/common-coding-style.instructions.md` | `**` |
| `rules/common/security.md` | `.github/instructions/common-security.instructions.md` | `**` |
| `rules/common/testing.md` | `.github/instructions/common-testing.instructions.md` | `**` |
| `rules/common/patterns.md` | `.github/instructions/common-patterns.instructions.md` | `**` |
| `rules/common/performance.md` | `.github/instructions/common-performance.instructions.md` | `**` |
| `rules/common/git-workflow.md` | `.github/instructions/git-workflow.instructions.md` | `**` |
| `rules/common/development-workflow.md` | `.github/instructions/dev-workflow.instructions.md` | `**` |
| `rules/common/code-review.md` | `.github/instructions/code-review.instructions.md` | `**` |
| `rules/typescript/*.md` | `.github/instructions/typescript.instructions.md` | `**/*.{ts,tsx,js,jsx}` |
| `rules/python/*.md` | `.github/instructions/python.instructions.md` | `**/*.py` |
| `rules/golang/*.md` | `.github/instructions/golang.instructions.md` | `**/*.go` |
| `rules/rust/*.md` | `.github/instructions/rust.instructions.md` | `**/*.rs` |
| `rules/java/*.md` | `.github/instructions/java.instructions.md` | `**/*.java` |
| `rules/kotlin/*.md` | `.github/instructions/kotlin.instructions.md` | `**/*.{kt,kts}` |
| `rules/cpp/*.md` | `.github/instructions/cpp.instructions.md` | `**/*.{cpp,cc,h,hpp}` |
| `rules/csharp/*.md` | `.github/instructions/csharp.instructions.md` | `**/*.cs` |
| `rules/swift/*.md` | `.github/instructions/swift.instructions.md` | `**/*.swift` |
| `rules/dart/*.md` | `.github/instructions/dart.instructions.md` | `**/*.dart` |
| `rules/perl/*.md` | `.github/instructions/perl.instructions.md` | `**/*.{pl,pm}` |
| `rules/php/*.md` | `.github/instructions/php.instructions.md` | `**/*.php` |
| `rules/web/*.md` | `.github/instructions/web.instructions.md` | `**/*.{html,css,scss}` |

### 変換例

```markdown
<!-- .github/instructions/typescript.instructions.md -->
---
applyTo: "**/*.{ts,tsx}"
---

# TypeScript ルール

<!-- rules/typescript/coding-style.md の内容 -->
<!-- rules/typescript/security.md の内容 -->
<!-- rules/typescript/testing.md の内容 -->
<!-- rules/typescript/patterns.md の内容 -->
```

> 注: `rules/*/hooks.md` は Claude Code 専用なので除外。

---

## 4. 🟢 軽微な変換で使用可 — Commands → `.prompt.md`

### Copilot のプロンプトファイル仕様

`.github/prompts/<name>.prompt.md` または VS Code ユーザープロンプトフォルダに配置。Chat で `/<name>` で呼び出し可能。

### 変換例

**ECC の `commands/plan.md`:**
```yaml
---
description: Restate requirements, assess risks, and create step-by-step implementation plan...
---

# Plan Command
（本文）
```

**Copilot 互換に変換 → `.github/prompts/plan.prompt.md`:**
```yaml
---
description: 実装計画を作成（要件確認 + リスク評価 + ステップ分解）
---

# Plan Command
（本文はそのまま）
```

### 流用価値の高いコマンド

| ECC コマンド | → Copilot プロンプト |
|------|------|
| `commands/plan.md` | `/plan` — 実装計画 |
| `commands/code-review.md` | `/code-review` — コードレビュー |
| `commands/build-fix.md` | `/build-fix` — ビルドエラー修正 |
| `commands/feature-dev.md` | `/feature-dev` — 機能開発 |
| `commands/refactor-clean.md` | `/refactor-clean` — リファクタリング |
| `commands/test-coverage.md` | `/test-coverage` — テストカバレッジ |
| `commands/update-docs.md` | `/update-docs` — ドキュメント更新 |
| `commands/review-pr.md` | `/review-pr` — PR レビュー |
| `commands/quality-gate.md` | `/quality-gate` — 品質ゲート |

---

## 5. ✅ そのまま使用可能 — その他

### 5.1 Contexts（コンテキスト切替）

| ファイル | 内容 | → Copilot での配置 |
|------|------|------|
| `contexts/dev.md` | 開発モード | `.github/instructions/dev-mode.instructions.md` または `.prompt.md` |
| `contexts/research.md` | 調査モード | 同上 |
| `contexts/review.md` | レビューモード | 同上 |

### 5.2 ルート階層のマークダウンファイル（リポジトリレベル指示）

ECC リポジトリのルートには **ECC の哲学・規約を凝縮した重要なマークダウンファイル**が複数存在します。これらは Copilot の `.github/copilot-instructions.md` に統合する**最高品質の素材**です。

#### 🟢 Copilot 指示として最優先で転記すべきファイル

| ファイル | 内容 | Copilot での活用 |
|------|------|------|
| **`SOUL.md`** | ECC のコアアイデンティティ — 5 つのコア原則（Agent-First / Test-Driven / Security-First / Immutability / Plan Before Execute） | `.github/copilot-instructions.md` の冒頭「Core Principles」として転記 |
| **`RULES.md`** | Must Always / Must Never の絶対ルール、agents/skills/hooks/commits のフォーマット規約 | `.github/copilot-instructions.md` の「Rules」セクションとして転記 |
| **`AGENTS.md`** | 48 エージェントの一覧とオーケストレーション指針、セキュリティ/コーディング/テスト要件 | `.github/copilot-instructions.md` の「Agent Orchestration」セクションとして転記、または `.github/agents/` 移植時のガイドとして参照 |
| **`CLAUDE.md`** | Claude Code 向けプロジェクト指示（テストコマンド、アーキテクチャ、開発ノート） | `.github/copilot-instructions.md` の「Project Setup」セクションとして転記 |

##### 推奨統合例（`.github/copilot-instructions.md`）

```markdown
# Project Copilot Instructions

## Core Principles
<!-- SOUL.md の "Core Principles" を転記 -->

## Rules
<!-- RULES.md の "Must Always" / "Must Never" を転記 -->

## Agent Orchestration
<!-- AGENTS.md の主要エージェント一覧と使い分けを転記 -->

## Project Setup
<!-- CLAUDE.md のテストコマンド・アーキテクチャを転記 -->

## Coding Standards / Security / Testing
<!-- rules/common/ から転記、または .github/instructions/ で分離 -->
```

#### 🔵 リファレンス・ナレッジベース（参照用）

直接 Copilot 機能と対応しないが、ドキュメントとして参照価値の高いもの：

| ファイル | 内容 | Copilot での活用 |
|------|------|------|
| `the-shortform-guide.md` | Claude Code 設定の実践ガイド（Anthropic ハッカソン優勝者執筆） | プロンプト設計の参考。skills/hooks/MCP 戦略の知見が Copilot 設計にも転用可 |
| `the-longform-guide.md` | shortform の続編 — トークン経済、メモリ永続化、検証パターン、並列化戦略 | 同上 |
| `the-security-guide.md` | エージェントセキュリティ解説（CVE 事例、攻撃ベクトル、MCP リスク） | Copilot で MCP を使う際のセキュリティチェックの参考 |
| `COMMANDS-QUICK-REF.md` | 全スラッシュコマンドのチートシート | `.github/prompts/` 移植時のリファレンス |
| `TROUBLESHOOTING.md` | トラブルシューティング | 参照のみ（Claude Code 固有の内容を含む） |
| `CONTRIBUTING.md` | コントリビューションガイド | リポジトリ標準ファイルとしてそのまま使用 |
| `SECURITY.md` | セキュリティポリシー | リポジトリ標準ファイルとしてそのまま使用 |
| `CODE_OF_CONDUCT.md` | 行動規範 | リポジトリ標準ファイルとしてそのまま使用 |
| `CHANGELOG.md` | 変更履歴 | リポジトリ標準ファイルとしてそのまま使用 |
| `README.md` / `README.zh-CN.md` | プロジェクト概要 | そのまま参照可 |

#### ⚪ 時点記録系（流用価値低）

ECC 内部の作業状況を記録した時点ドキュメント。Copilot 用には流用不要：

| ファイル | 内容 |
|------|------|
| `WORKING-CONTEXT.md` | リポジトリの作業状態（2026-04-08 時点） |
| `REPO-ASSESSMENT.md` | フォーク評価とセットアップ推奨（2026-03-21 時点） |
| `EVALUATION.md` | 既存セットアップとの比較評価（2026-03-21 時点） |
| `SPONSORS.md` / `SPONSORING.md` | スポンサー一覧 |

### 5.3 MCP サーバー設定

`mcp-configs/mcp-servers.json` に定義された 17 サーバーは VS Code Copilot Chat の MCP サポート、もしくは Copilot のカスタムエージェントの `mcp-servers` プロパティで利用可能：

| MCP サーバー | 用途 |
|------|------|
| `github` | GitHub PR/Issue 操作 |
| `context7` | ライブドキュメント検索 |
| `playwright` | ブラウザ自動化 |
| `filesystem` | ファイルシステム操作 |
| `sequential-thinking` | 思考連鎖 |
| `exa-web-search` | Web 検索 |
| `memory` / `omega-memory` | 永続メモリ |
| `jira` / `confluence` | Atlassian 連携 |
| `firecrawl` | Web スクレイピング |
| `supabase` | Supabase DB |
| `vercel` / `railway` | デプロイ管理 |
| `cloudflare-docs` 他 | Cloudflare 連携 |
| `fal-ai` | AI メディア生成 |
| `clickhouse` | ClickHouse 分析 |
| `evalview` | エージェント回帰テスト |
| `token-optimizer` | トークン最適化 |

カスタムエージェントへの組み込み例：
```yaml
---
name: db-specialist
description: PostgreSQL/Supabase 設計レビュー
tools: ["read", "search", "supabase/query"]
mcp-servers:
  - name: supabase
    command: npx
    args: ["-y", "@supabase/mcp-server-supabase@latest"]
---
```

---

## 6. ❌ Copilot で使用不可なもの

| カテゴリ | 内容 | 理由 |
|---------|------|------|
| `hooks/hooks.json` | Claude Code hooks（PreToolUse, PostToolUse, PreCompact 等） | Claude Code 専用トリガー |
| `scripts/hooks/` | Hook 実行スクリプト群 | Claude Code ランタイム依存 |
| `rules/*/hooks.md` | 言語別 hooks 定義 | Claude Code 専用 |
| `ecc2/` | ECC v2 Rust 実装 | Claude Code CLI ツール |
| `install.sh` / `install.ps1` | ECC インストーラー | `~/.claude/` 設定用 |
| `agent.yaml` | gitagent エクスポート定義 | Claude Code プラグインマニフェスト |
| `.codex/`, `.cursor/`, `.gemini/`, `.kiro/`, `.opencode/`, `.trae/` | 他 AI ツール固有設定 | 各ツール専用形式 |
| `src/llm/` | LLM ユーティリティ | Claude Code 内部ツール |

> ECC は複数の hooks ランタイム（pre-bash, doc-warning, suggest-compact, governance-capture 等）を持ちますが、これは Claude Code のツール実行イベントにフックするもので、Copilot には同等機構がありません。

---

## 7. 推奨セットアップ手順

### ステップ 1: Skills のネイティブ移植（最も簡単で効果大）

```powershell
# ECC リポジトリ内で実行（Windows PowerShell）
$src = "skills"
$dst = ".github/skills"
New-Item -ItemType Directory -Force -Path $dst | Out-Null
Get-ChildItem $src -Directory | ForEach-Object {
  Copy-Item $_.FullName -Destination $dst -Recurse -Force
}
```

→ これだけで 182 スキルが Copilot で使用可能に。

### ステップ 2: Rules を `.github/instructions/` に変換

各言語ごとに `.instructions.md` ファイルを 1 つずつ作成し、`applyTo` を設定して `rules/<lang>/coding-style.md` 等の内容を統合。

### ステップ 3: Agents を `.github/agents/` に配置

主要な 5〜10 個のレビュアーエージェントから優先的に：
- `code-reviewer.agent.md`
- `security-reviewer.agent.md`
- `<言語>-reviewer.agent.md`（プロジェクトの主要言語）
- `planner.agent.md`
- `architect.agent.md`

ツール名を `read`/`edit`/`search`/`shell` に変換、`model` 行を削除。

### ステップ 4: Commands を `.github/prompts/` に配置

`/plan`, `/code-review`, `/build-fix` 等の主要コマンドから優先的に。

### ステップ 5: MCP サーバーを設定

VS Code `settings.json` に追加、または特定のエージェントの `mcp-servers` プロパティに記載。

### ステップ 6: ルート階層 MD を `copilot-instructions.md` に統合

最も効果的かつ簡単なステップの一つ。`SOUL.md` / `RULES.md` / `AGENTS.md` / `CLAUDE.md` から以下のように `.github/copilot-instructions.md` を構築：

```markdown
# Project Copilot Instructions

## Core Principles            ← SOUL.md より転記
## Rules (Must Always/Never)  ← RULES.md より転記
## Agent Orchestration        ← AGENTS.md より転記
## Project Setup              ← CLAUDE.md より転記
## Coding Standards           ← rules/common/coding-style.md より転記
## Security                   ← rules/common/security.md より転記
## Testing                    ← rules/common/testing.md より転記
```

これだけで Copilot がリポジトリ全体に対して ECC の哲学・ルールを適用するようになります。

---

## 8. 数量サマリー（改訂版）

| カテゴリ | 総数 | ✅ ネイティブ互換 | 🟢 軽微な変換で使用可 | ❌ 使用不可 |
|---------|------|------------------|--------------------|------------|
| Skills (`skills/` + `.agents/skills/` + `.claude/skills/`) | 215 | 33（既にネイティブパス） | 182（コピーのみ） | — |
| Agents | 48 | — | 48（フロントマター変換） | — |
| Rules（言語別、hooks 除く） | 52 | — | 52（applyTo 追加） | — |
| Rules（共通、hooks 除く） | 8〜10 | — | 8〜10（applyTo 追加） | — |
| Rules（hooks.md） | 13 | — | — | 13 |
| Commands | 68 | — | 68（description 調整） | — |
| Contexts | 3 | — | 3 | — |
| ルートレベル MD（哲学・規約） | 4（SOUL/RULES/AGENTS/CLAUDE） | — | 4（copilot-instructions.md に転記） | — |
| ルートレベル MD（ガイド・記事） | 7+（the-*-guide, COMMANDS-QUICK-REF, TROUBLESHOOTING 等） | 7+（参照ドキュメント） | — | — |
| ルートレベル MD（時点記録） | 3（WORKING-CONTEXT/REPO-ASSESSMENT/EVALUATION） | — | — | 3（流用価値低） |
| MCP 設定 | 17 サーバー | 17 | — | — |
| Hooks ランタイム | 8+ | — | — | 8+ |
| Scripts/Installer | 30+ | — | — | 30+ |

**合計**: 約 **480+ ファイル** のうち、**約 380+ ファイル（約 79%）が Copilot で活用可能**

---

## 9. 結論（改訂）

GitHub Copilot のカスタムエージェント / スキル / インストラクション機能は **ECC の構造とほぼ 1 対 1 で対応** しており、Claude Code 専用と思われていた資産の大半が **そのままもしくはわずかな変換で Copilot に移植可能** です。

### 特に重要なポイント

1. **Skills は実質ネイティブ互換** — Copilot は `.claude/skills/` と `.agents/skills/` を直接読み込むため、ECC のリポジトリで Copilot を使えば既に一部スキルは認識される可能性が高い
2. **Agents もほぼ互換** — フロントマターのツール名小文字化と model 行調整のみで `.github/agents/*.agent.md` として動作
3. **Rules は分割インストラクション化** — `.github/instructions/` に複数 `.instructions.md` を `applyTo` 付きで配置すれば言語別ルールが自動適用
4. **Commands はプロンプトファイル化** — `.github/prompts/*.prompt.md` でスラッシュコマンドとして再利用可能
5. **MCP サーバーは双方共通仕様** — 設定をそのまま流用可能

### 移植しても動かないもの

Claude Code 専用機能：
- **Hooks** (PreToolUse/PostToolUse) — Copilot に同等機構なし
- **`Task` ツールによる自動エージェント委譲** — Copilot のカスタムエージェントは手動選択方式
- **ECC インストーラー / スクリプト群** — `~/.claude/` 構造への配置用

### 最も価値の高い初動

最も効果が高い順：

1. **`.github/skills/` に ECC の skills/ をコピー** — 即座に 182 スキルが利用可能
2. **`.github/copilot-instructions.md` に `rules/common/` を集約** — 全リポジトリで適用される基本ルール
3. **`.github/instructions/<lang>.instructions.md` で言語別ルール** — `applyTo` で自動適用
4. **`.github/agents/<role>.agent.md` で主要レビュアー** — 言語別レビューエージェントを移植
5. **`.github/prompts/*.prompt.md` で頻用コマンド** — `/plan`, `/code-review` 等

この順序で進めれば、ECC の知識資産の **約 80% を GitHub Copilot 上で再利用** できます。
