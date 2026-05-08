# GitHub Copilot 統合バンドル

> ECC（Everything Claude Code）の知識資産を **GitHub Copilot Chat / CLI / クラウドエージェント** で利用可能な形式に変換したバンドルです。
>
> このディレクトリは **そのまま既存のリポジトリにコピー** して使えます。

---

## 📂 構造

```
GithubCopilot/
├── README.md                      ← このファイル
├── setup.ps1                      ← Windows: skills 一括コピースクリプト
├── setup.sh                       ← macOS/Linux: skills 一括コピースクリプト
├── mcp/
│   └── mcp.json                   ← MCP サーバー設定（VS Code settings.json に転記）
└── .github/
    ├── copilot-instructions.md    ← 全リポジトリ自動適用される指示（SOUL/RULES/AGENTS/CLAUDE 統合）
    ├── instructions/              ← 言語別ルール（applyTo で自動適用）
    │   ├── typescript.instructions.md
    │   ├── python.instructions.md
    │   ├── golang.instructions.md
    │   ├── rust.instructions.md
    │   ├── java.instructions.md
    │   ├── kotlin.instructions.md
    │   ├── cpp.instructions.md
    │   ├── csharp.instructions.md
    │   ├── swift.instructions.md
    │   ├── dart.instructions.md
    │   ├── php.instructions.md
    │   ├── perl.instructions.md
    │   └── web.instructions.md
    ├── agents/                    ← Copilot カスタムエージェント
    │   ├── code-reviewer.agent.md
    │   ├── security-reviewer.agent.md
    │   ├── planner.agent.md
    │   ├── architect.agent.md
    │   ├── tdd-guide.agent.md
    │   ├── typescript-reviewer.agent.md
    │   ├── python-reviewer.agent.md
    │   ├── go-reviewer.agent.md
    │   ├── rust-reviewer.agent.md
    │   ├── build-error-resolver.agent.md
    │   ├── refactor-cleaner.agent.md
    │   ├── doc-updater.agent.md
    │   └── e2e-runner.agent.md
    ├── prompts/                   ← Copilot Chat スラッシュコマンド
    │   ├── plan.prompt.md
    │   ├── code-review.prompt.md
    │   ├── build-fix.prompt.md
    │   ├── feature-dev.prompt.md
    │   ├── test-coverage.prompt.md
    │   ├── refactor-clean.prompt.md
    │   ├── update-docs.prompt.md
    │   └── quality-gate.prompt.md
    └── skills/                    ← Copilot カスタムスキル（5 つ収録、残りは setup スクリプトで一括コピー）
        ├── tdd-workflow/
        │   └── SKILL.md
        ├── security-review/
        │   └── SKILL.md
        ├── api-design/
        │   └── SKILL.md
        ├── coding-standards/
        │   └── SKILL.md
        └── git-workflow/
            └── SKILL.md
```

---

## 🚀 クイックスタート

### Step 1: 既存リポジトリにコピー

GitHub Copilot を使いたいプロジェクトのルートに `.github/` をコピー:

```powershell
# Windows PowerShell
$dest = "C:\path\to\your\project"
Copy-Item -Path ".github" -Destination $dest -Recurse -Force
```

```bash
# macOS / Linux
DEST="/path/to/your/project"
cp -R .github "$DEST/"
```

### Step 2: スキルを追加（オプション、推奨）

ECC リポジトリに 182 個のスキルがあります。setup スクリプトで一括コピー:

```powershell
# Windows
.\setup.ps1
# 全エージェントとコマンドも変換する場合:
.\setup.ps1 -IncludeAllAgents -IncludeAllCommands
```

```bash
# macOS / Linux
./setup.sh
# 全エージェントとコマンドも変換する場合:
./setup.sh --include-all-agents --include-all-commands
```

### Step 3: MCP サーバー設定（オプション）

VS Code の `settings.json` を開き、`mcp/mcp.json` の内容を `github.copilot.chat.mcp.servers` に追加:

```jsonc
{
  "github.copilot.chat.mcp.servers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_xxx"
      }
    }
    // ...
  }
}
```

### Step 4: Copilot で確認

VS Code または `gh copilot` CLI で:
- リポジトリ全体に `copilot-instructions.md` が自動適用される
- `.ts` ファイルを編集すると `typescript.instructions.md` が自動適用される
- Chat で `/plan`, `/code-review` 等を実行できる
- `@code-reviewer`, `@security-reviewer` 等のカスタムエージェントを呼び出せる

---

## 📋 各ファイルの役割

### `.github/copilot-instructions.md`

**全リポジトリ・全ファイルに自動適用される指示**。

ECC の以下の内容を統合:
- `SOUL.md` の Core Principles（5 原則）
- `RULES.md` の Must Always / Must Never
- `AGENTS.md` のエージェントオーケストレーション
- `CLAUDE.md` のプロジェクト設定
- `rules/common/*` のすべてのルール

### `.github/instructions/<lang>.instructions.md`

**言語別ルール**。フロントマターの `applyTo` でファイルパターンに自動適用。

| ファイル | 適用対象 |
|---------|---------|
| `typescript.instructions.md` | `**/*.{ts,tsx,js,jsx,mjs,cjs}` |
| `python.instructions.md` | `**/*.{py,pyi}` |
| `golang.instructions.md` | `**/*.go` |
| `rust.instructions.md` | `**/*.rs` |
| `java.instructions.md` | `**/*.java` |
| `kotlin.instructions.md` | `**/*.{kt,kts}` |
| `cpp.instructions.md` | `**/*.{cpp,hpp,cc,hh,cxx,h,c}` |
| `csharp.instructions.md` | `**/*.{cs,csx}` |
| `swift.instructions.md` | `**/*.swift` |
| `dart.instructions.md` | `**/*.dart` |
| `php.instructions.md` | `**/*.php` |
| `perl.instructions.md` | `**/*.{pl,pm,t,psgi,cgi}` |
| `web.instructions.md` | `**/*.{html,htm,css,scss,sass,less}` |

### `.github/agents/*.agent.md`

**Copilot カスタムエージェント**。Chat または CLI から `@agent-name` または `/agent` で呼び出し可能。

| エージェント | 用途 |
|-------------|------|
| `code-reviewer` | 汎用コードレビュー |
| `security-reviewer` | OWASP Top 10 セキュリティレビュー |
| `planner` | 実装計画作成 |
| `architect` | システム設計 |
| `tdd-guide` | TDD ワークフロー |
| `typescript-reviewer` | TypeScript 専門レビュー |
| `python-reviewer` | Python 専門レビュー |
| `go-reviewer` | Go 専門レビュー |
| `rust-reviewer` | Rust 専門レビュー |
| `build-error-resolver` | ビルドエラー解決 |
| `refactor-cleaner` | デッドコード除去 |
| `doc-updater` | ドキュメント更新 |
| `e2e-runner` | Playwright E2E テスト |

### `.github/prompts/*.prompt.md`

**Copilot Chat スラッシュコマンド**。Chat で `/plan` のように呼び出し可能。

| プロンプト | 用途 |
|-----------|------|
| `/plan` | 実装計画策定（コード書く前に確認待ち） |
| `/code-review` | コードレビュー（ローカル または PR） |
| `/build-fix` | ビルド / 型エラー修正 |
| `/feature-dev` | ガイド付き機能開発 |
| `/test-coverage` | カバレッジ分析・テスト生成 |
| `/refactor-clean` | デッドコード除去 |
| `/update-docs` | ドキュメント同期 |
| `/quality-gate` | 品質ゲートチェック |

### `.github/skills/<name>/SKILL.md`

**Copilot カスタムスキル**。Copilot が文脈に応じて自動的に参照する知識ベース。

このバンドルには 5 つのコアスキルが収録されています:
- `tdd-workflow` — TDD ワークフロー
- `security-review` — セキュリティチェックリスト
- `api-design` — REST API 設計パターン
- `coding-standards` — コーディング規約
- `git-workflow` — Git ワークフロー

**追加の 177 スキルは `setup.ps1` / `setup.sh` で一括コピー可能**:

```powershell
.\setup.ps1
```

---

## 🎛️ 設定のカスタマイズ

### プロジェクト固有のルールを追加

`.github/copilot-instructions.md` に以下のセクションを追加:

```markdown
## Project-Specific Rules

- このプロジェクトでは Vue 3 を使用（React ではない）
- 状態管理は Pinia
- スタイリングは Tailwind CSS
```

### 言語ルールをカスタマイズ

`.github/instructions/typescript.instructions.md` を編集してプロジェクトの規約を追加:

```markdown
## Project-Specific TypeScript Rules

- バリデーションは Zod のみ（Yup, Joi 不可）
- DI コンテナは tsyringe を使用
```

### エージェントを追加

`.github/agents/<name>.agent.md` を作成:

```markdown
---
description: <用途説明>
tools: ["read", "search", "edit"]
---

エージェントのプロンプト本文（最大 30,000 文字）
```

### MCP サーバーを追加

`mcp/mcp.json` を編集して、VS Code `settings.json` に再度転記。

---

## 📚 参考資料

- [GitHub Copilot カスタムエージェント](https://docs.github.com/ja/copilot/how-tos/copilot-on-github/customize-copilot/customize-cloud-agent/create-custom-agents)
- [GitHub Copilot エージェントスキル](https://docs.github.com/ja/copilot/how-tos/copilot-on-github/customize-copilot/customize-cloud-agent/add-skills)
- [VS Code Copilot Instructions](https://docs.github.com/en/copilot/customizing-copilot/adding-custom-instructions-for-github-copilot)
- [Awesome Copilot](https://github.com/github/awesome-copilot) — コミュニティスキル / エージェント集
- [元 ECC リポジトリ](https://github.com/affaan-m/everything-claude-code)

---

## 🔄 ECC との対応関係

| ECC | → | GitHub Copilot |
|-----|---|----------------|
| `SOUL.md`, `RULES.md`, `AGENTS.md`, `CLAUDE.md` | → | `.github/copilot-instructions.md` |
| `rules/<lang>/*.md` | → | `.github/instructions/<lang>.instructions.md` |
| `agents/*.md` | → | `.github/agents/*.agent.md` |
| `commands/*.md` | → | `.github/prompts/*.prompt.md` |
| `skills/*/SKILL.md` | → | `.github/skills/*/SKILL.md`（無変換、`origin: ECC` 行のみ削除） |
| `mcp-configs/mcp-servers.json` | → | `mcp/mcp.json`（VS Code `settings.json` に転記） |

**変換不可のもの**:
- `hooks/hooks.json` — Claude Code 専用イベントトリガー
- `scripts/hooks/*` — Claude Code ランタイム依存
- `ecc2/`, `install.sh`, `install.ps1` — Claude Code インストーラー

---

## 📝 ライセンス

元の ECC リポジトリは MIT ライセンス。このバンドルも同様。
