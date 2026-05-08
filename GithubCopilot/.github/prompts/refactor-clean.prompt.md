---
description: 各変更後の検証付きで安全にデッドコードを特定して除去。
---

# /refactor-clean — Refactor & Clean

各ステップでテスト検証付きでデッドコードを安全に特定して除去する。

## Step 1: デッドコード検出

プロジェクトタイプに基づいて分析ツールを実行:

| ツール | 検出するもの | コマンド |
|------|--------------|---------|
| knip | 未使用エクスポート、ファイル、依存関係 | `npx knip` |
| depcheck | 未使用 npm 依存関係 | `npx depcheck` |
| ts-prune | 未使用 TypeScript エクスポート | `npx ts-prune` |
| vulture | 未使用 Python コード | `vulture src/` |
| deadcode | 未使用 Go コード | `deadcode ./...` |
| cargo-udeps | 未使用 Rust 依存関係 | `cargo +nightly udeps` |

## Step 2: 発見をカテゴリ化

発見を安全層にソート:

| 層 | 例 | アクション |
|-----|-----|----------|
| **SAFE** | 未使用ユーティリティ、テストヘルパー、内部関数 | 自信を持って削除 |
| **CAUTION** | コンポーネント、API ルート、ミドルウェア | 動的 import や外部消費者がないことを検証 |
| **DANGER** | 設定ファイル、エントリポイント、型定義 | 触る前に調査 |

## Step 3: 安全削除ループ

各 SAFE 項目について:

1. **フルテストスイート実行** — ベースライン確立（すべてグリーン）
2. **デッドコードを削除** — 外科的除去
3. **テストスイート再実行** — 何も壊れていないことを検証
4. **テストが失敗したら** — すぐに `git checkout -- <file>` で元に戻し、この項目をスキップ
5. **テストがパスしたら** — 次の項目へ進む

## Step 4: CAUTION 項目の処理

CAUTION 項目を削除する前に:
- 動的 import を検索: `import()`, `require()`, `__import__`
- リフレクション / メタプログラミングをチェック
- 外部リポジトリでの使用を確認（モノレポの場合）
- 削除を検証するためにテストカバレッジを実行

## Step 5: バッチコミット

- 一度に 1 カテゴリずつコミット: deps → exports → files → 重複
- conventional commit メッセージ: `refactor: remove unused exports`
- ロールバックを容易にするため小さく独立したコミット
