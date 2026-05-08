---
description: スクリプト、スキーマ、ルート、エクスポートなどの真実のソースファイルからドキュメントを同期。
---

# /update-docs — Update Documentation

コードベースとドキュメントを同期し、真実のソースファイルから生成する。

## Step 1: 真実のソースを特定

| ソース | 生成するもの |
|--------|-----------|
| `package.json` scripts | 利用可能なコマンドリファレンス |
| `.env.example` | 環境変数ドキュメント |
| `openapi.yaml` / ルートファイル | API エンドポイントリファレンス |
| ソースコードエクスポート | パブリック API ドキュメント |
| `Dockerfile` / `docker-compose.yml` | インフラセットアップドキュメント |

## Step 2: スクリプトリファレンス生成

1. `package.json`（または `Makefile`、`Cargo.toml`、`pyproject.toml`）を読む
2. 説明と共にすべてのスクリプト / コマンドを抽出
3. リファレンステーブル生成:

```markdown
| Command | Description |
|---------|-------------|
| `npm run dev` | ホットリロード付きで開発サーバーを起動 |
| `npm run build` | 型チェック付きプロダクションビルド |
| `npm test` | カバレッジ付きでテストスイートを実行 |
```

## Step 3: 環境ドキュメント生成

1. `.env.example`（または `.env.template`、`.env.sample`）を読む
2. 目的と共にすべての変数を抽出
3. 必須 vs オプションでカテゴリ化
4. 期待されるフォーマットと有効値を文書化

```markdown
| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `DATABASE_URL` | Yes | PostgreSQL 接続文字列 | `postgres://user:pass@host:5432/db` |
| `LOG_LEVEL` | No | ロギング詳細度（デフォルト: info） | `debug`, `info`, `warn`, `error` |
```

## Step 4: コントリビューションガイド更新

`docs/CONTRIBUTING.md` を生成または更新:
- 開発環境セットアップ（前提条件、インストール手順）
- ローカルでテストを実行する方法
- 貢献するためのワークフロー（branch、commit、PR）
- コードスタイルとレビュー基準
