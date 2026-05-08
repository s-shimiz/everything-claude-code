---
name: git-workflow
description: Git workflow patterns including branching strategies, commit conventions, merge vs rebase, conflict resolution, and collaborative development best practices for teams of all sizes.
---

# Git Workflow Patterns

Git バージョン管理、ブランチング戦略、共同開発のベストプラクティス。

## When to Activate

- 新しいプロジェクトの Git ワークフローセットアップ
- ブランチング戦略の決定（GitFlow、trunk-based、GitHub flow）
- コミットメッセージと PR 説明の作成
- マージ競合の解決
- リリースとバージョンタグの管理
- 新しいチームメンバーを Git プラクティスにオンボード

## Branching Strategies

### GitHub Flow（シンプル、推奨）

継続的デプロイメントと中小規模チームに最適:

```
main (保護、常にデプロイ可能)
  ├── feature/user-auth      → PR → main にマージ
  ├── feature/payment-flow   → PR → main にマージ
  └── fix/login-bug          → PR → main にマージ
```

ルール:
- `main` は常にデプロイ可能
- `main` から feature ブランチを作成
- レビューの準備ができたら PR をオープン
- 承認と CI パス後、`main` にマージ
- マージ後すぐにデプロイ

### Trunk-Based Development（高速チーム）

強力な CI/CD と feature flag を持つチームに最適:

```
main (trunk)
  ├── 短命 feature (1-2 日 max)
  └── 短命 feature
```

### GitFlow（複雑、リリースサイクル駆動）

スケジュールされたリリースとエンタープライズプロジェクトに最適:

```
main (本番リリース)
  └── develop (統合ブランチ)
        ├── feature/user-auth
        ├── release/1.0.0    → main と develop にマージ
        └── hotfix/critical  → main と develop にマージ
```

| 戦略 | チームサイズ | リリース頻度 | 最適 |
|------|------------|-------------|------|
| GitHub Flow | 任意 | 継続的 | SaaS、Web アプリ、スタートアップ |
| Trunk-Based | 5+ 経験者 | 1 日複数 | 高速チーム、feature flags |
| GitFlow | 10+ | スケジュール | エンタープライズ、規制業界 |

## Commit Messages

### Conventional Commits

```
<type>(<scope>): <subject>

[optional body]

[optional footer(s)]
```

| Type | 用途 | 例 |
|------|-----|-----|
| `feat` | 新機能 | `feat(auth): add OAuth2 login` |
| `fix` | バグ修正 | `fix(api): handle null response` |
| `docs` | ドキュメント | `docs(readme): update install instructions` |
| `refactor` | リファクタリング | `refactor(db): extract connection pool` |
| `test` | テスト追加 / 更新 | `test(auth): add unit tests for token validation` |
| `chore` | メンテナンス | `chore(deps): update dependencies` |
| `perf` | パフォーマンス改善 | `perf(query): add index to users table` |
| `ci` | CI/CD 変更 | `ci: add PostgreSQL service to test workflow` |

### Good vs Bad

```bash
# BAD
git commit -m "fixed stuff"
git commit -m "updates"
git commit -m "WIP"

# GOOD
git commit -m "fix(api): retry requests on 503 Service Unavailable

The external API occasionally returns 503 errors during peak hours.
Added exponential backoff retry logic with max 3 attempts.

Closes #123"
```

## Merge vs Rebase

### Merge（履歴を保持）

```bash
git checkout main
git merge feature/user-auth
```

使うとき:
- feature ブランチを `main` にマージ
- 履歴を正確に保持したい
- 複数の人がブランチで作業
- ブランチが push 済みで他のメンバーが作業をベースにしている可能性

### Rebase（線形履歴）

```bash
git checkout feature/user-auth
git rebase main
```

使うとき:
- ローカル feature ブランチを最新 `main` で更新
- 線形でクリーンな履歴を望む
- ブランチがローカルのみ（push されていない）
- 自分だけがブランチで作業

## Conflict Resolution

```bash
# rebase 中の競合
git status                       # 競合ファイルを確認
# ファイルを編集して競合を解決
git add <resolved-files>
git rebase --continue

# rebase を中止
git rebase --abort

# マージ競合
git status
git add <resolved-files>
git commit  # マージコミットを作成
```

## Pull Request Workflow

1. **コミット履歴を分析**: `git log <base>..HEAD`
2. **包括的な PR 説明を作成**:
   - 何が変更されたか
   - なぜ変更されたか
   - どのように動作するか
   - スクリーンショット / ビデオ（UI 変更の場合）
   - テストプラン
3. **テンプレート使用**:
```markdown
## What
[簡潔な変更の説明]

## Why
[コンテキストとモチベーション]

## How
[実装アプローチ]

## Testing
- [ ] ユニットテスト追加
- [ ] 統合テスト追加
- [ ] 手動テスト済み

## Screenshots
[UI 変更の場合]

Closes #123
```
4. **新しいブランチを `-u` フラグでプッシュ**: `git push -u origin <branch>`

## Tags & Releases

```bash
# Semantic versioning
git tag -a v1.2.3 -m "Release version 1.2.3"
git push origin v1.2.3

# 全タグをプッシュ
git push origin --tags

# タグを削除
git tag -d v1.2.3
git push origin :refs/tags/v1.2.3
```
