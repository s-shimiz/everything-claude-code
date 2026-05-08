---
description: コードレビュー — ローカルの未コミット変更または GitHub PR (PR 番号 / URL を渡すと PR モード)
---

# /code-review — Code Review

ローカル未コミット変更または GitHub PR の包括的レビュー。

## モード選択

- 引数に PR 番号 / URL / `--pr` が含まれる → **PR Review Mode**
- それ以外 → **Local Review Mode**

## Local Review Mode

未コミット変更の包括的セキュリティ・品質レビュー。

### Phase 1 — GATHER

```bash
git diff --name-only HEAD
```

変更ファイルがなければ停止: "Nothing to review."

### Phase 2 — REVIEW

各変更ファイルを完全に読む。チェック:

**セキュリティ問題（CRITICAL）:**
- ハードコードされた認証情報、API キー、トークン
- SQL injection 脆弱性
- XSS 脆弱性
- 入力検証の欠落
- セキュアでない依存関係
- パストラバーサルリスク

**コード品質（HIGH）:**
- 関数 > 50 行
- ファイル > 800 行
- ネスト深度 > 4 レベル
- エラー処理欠落
- console.log ステートメント
- TODO/FIXME コメント
- パブリック API への JSDoc 欠落

**ベストプラクティス（MEDIUM）:**
- ミューテーションパターン（不変を使用）
- コード/コメントでの絵文字使用
- 新しいコードへのテスト欠落
- アクセシビリティ問題（a11y）

### Phase 3 — REPORT

レポート生成:
- 重要度: CRITICAL, HIGH, MEDIUM, LOW
- ファイル位置と行番号
- 問題の説明
- 修正提案

CRITICAL または HIGH 問題があればコミットをブロック。
セキュリティ脆弱性のあるコードは決して承認しない。

## PR Review Mode

```bash
gh pr view <NUMBER> --json number,title,body,author,baseRefName,headRefName,changedFiles,additions,deletions
gh pr diff <NUMBER>
```

### Phase 1 — FETCH
PR メタデータ + diff 取得

### Phase 2 — CONTEXT
ベースブランチからの変更を分析、関連ファイルを読む

### Phase 3 — REVIEW
Local Review Mode と同じチェックリスト

### Phase 4 — POST
GitHub PR レビューとして投稿（`gh pr review`）
