# GitHub Copilot Hooks

ECC の hooks ロジックを GitHub Copilot Hooks フォーマット（[公式ドキュメント](https://docs.github.com/ja/copilot/how-tos/copilot-on-github/customize-copilot/customize-cloud-agent/use-hooks)）に移植したものです。

## 構成

```
.github/hooks/
├── hooks.json              # フック定義（version: 1）
└── scripts/
    ├── session-start.{sh,ps1}      # sessionStart
    ├── session-end.{sh,ps1}        # sessionEnd
    ├── config-protection.{sh,ps1}  # preToolUse — linter/formatter 設定保護
    ├── doc-file-warning.{sh,ps1}   # preToolUse — ad-hoc ドキュ警告
    ├── secrets-scan.{sh,ps1}       # preToolUse — シークレット検出
    ├── no-verify-block.{sh,ps1}    # preToolUse — --no-verify ブロック
    ├── post-edit-format.{sh,ps1}   # postToolUse — 自動フォーマット
    └── error-log.{sh,ps1}          # errorOccurred — エラーログ
```

## 動作するフック

| トリガー | 用途 | Exit code 動作 |
|---------|------|---------------|
| `sessionStart` | セッション開始ログ | 0 のみ |
| `sessionEnd` | セッション終了ログ + 未コミット警告 | 0 のみ |
| `preToolUse` (config-protection) | 設定ファイル改変ブロック | 2 でブロック |
| `preToolUse` (doc-file-warning) | ad-hoc 名 .md/.txt 警告 | 0 のみ（警告） |
| `preToolUse` (secrets-scan) | ハードコードシークレット検出 | 2 でブロック |
| `preToolUse` (no-verify-block) | `git --no-verify` ブロック | 2 でブロック |
| `postToolUse` (post-edit-format) | 編集後の自動フォーマット | 0 のみ |
| `errorOccurred` (error-log) | エラーログ記録 | 0 のみ |

## 使い方

### 1. リポジトリへ配置

`.github/hooks/` ディレクトリ配下のファイルを、Copilot を有効にしたいリポジトリにコピー。

### 2. 実行権限を付与（macOS / Linux）

```bash
chmod +x .github/hooks/scripts/*.sh
```

### 3. デフォルトブランチへマージ

Copilot Cloud Agent 用には `hooks.json` がデフォルトブランチ（`main`）にコミットされている必要があります。

### 4. 動作確認

ローカルで bash スクリプトを直接呼び出してテスト:

```bash
# config-protection — eslint.config.js を編集しようとしたケース
echo '{"toolArgs":"{\"file_path\":\"eslint.config.js\"}"}' \
  | ./.github/hooks/scripts/config-protection.sh
echo "Exit code: $?"   # → 2 でブロック

# secrets-scan — シークレットを含む内容
echo '{"toolArgs":"{\"file_path\":\"src/api.ts\",\"content\":\"const key = \\\"sk-proj-abc12345xyz\\\"\"}"}' \
  | ./.github/hooks/scripts/secrets-scan.sh
echo "Exit code: $?"   # → 2 でブロック
```

## カスタマイズ

### 保護対象ファイルを追加（config-protection）

`scripts/config-protection.sh` の `PROTECTED_FILES` 配列に追加。
`scripts/config-protection.ps1` の `$protectedFiles` も同様に編集。

### シークレットパターン追加（secrets-scan）

`scripts/secrets-scan.sh` の `PATTERNS` 配列、`scripts/secrets-scan.ps1` の `$patterns` を編集。

### フックの無効化

`hooks.json` の `hooks` オブジェクトから該当エントリを削除。

## トラブルシューティング

### フックが実行されない

- `hooks.json` がリポジトリの**デフォルトブランチ**にあるか確認
- JSON 構文が有効か検証: `jq . .github/hooks/hooks.json`
- スクリプトに実行権限があるか確認: `ls -la .github/hooks/scripts/`
- shebang 行が正しいか（`#!/usr/bin/env bash`）

### タイムアウトする

`hooks.json` の `timeoutSec` を増やす（デフォルト 30 秒）:

```json
{
  "type": "command",
  "bash": "./.github/hooks/scripts/post-edit-format.sh",
  "timeoutSec": 60
}
```

### Exit code 2 でブロックされた

`stderr` に出力されるメッセージを確認。修正アクションが記載されています。

## ECC オリジナルとの差分

| ECC 機能 | Copilot 移植版 | 備考 |
|---------|---------------|------|
| Node.js ランタイム + dispatcher | bash / PowerShell スタンドアロン | dispatcher なし、各スクリプトが独立 |
| `ECC_HOOK_PROFILE` ゲーティング | 未実装 | 必要なら hooks.json でフック単位に切替 |
| `pre-bash-dispatcher.js` の複合チェック | 個別スクリプトに分割 | config-protection, no-verify-block 等 |
| `governance-capture.js` | 未移植 | 専用バックエンドが必要なため |
| `observe-runner.js` | 未移植 | ECC ランタイム依存 |
| `suggest-compact.js` | 未移植 | Copilot に compact 概念なし |
| `gateguard-fact-force.js` | 未移植 | ECC 状態管理に依存 |
| `mcp-health-check.js` | 未移植 | Copilot MCP の API が異なる |
