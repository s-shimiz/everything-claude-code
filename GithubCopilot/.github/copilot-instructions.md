# Copilot Instructions

> ECC（Everything Claude Code）の哲学・規約を GitHub Copilot 向けに移植したインストラクション。
> リポジトリ全体に自動適用される。言語別ルールは `.github/instructions/` を参照。

---

## Core Identity

このプロジェクトは ECC のコア原則に従う AI コーディングプラグイン / プロジェクトとして扱う。

### Core Principles

1. **Agent-First** — 専門領域のタスクは、できるだけ早い段階で適切なスペシャリストエージェントに委譲する
2. **Test-Driven** — 実装変更を信頼する前に、テストを書くか更新する
3. **Security-First** — 入力を検証し、シークレットを保護し、安全なデフォルトを保つ
4. **Immutability** — 変更ではなく、明示的な状態遷移を優先する
5. **Plan Before Execute** — 複雑な変更は意図的なフェーズに分解する

---

## Rules (Must Always / Must Never)

### Must Always

- ドメインタスクは専門エージェント（プロンプト）に委譲する
- 実装の前にテストを書き、クリティカルパスを検証する
- 入力を検証し、セキュリティチェックを維持する
- 共有状態のミューテーションよりイミュータブルな更新を優先する
- 新しいパターンを発明する前に、既存のリポジトリパターンに従う
- 貢献は焦点を絞り、レビュー可能で、明確に説明された形にする

### Must Never

- 機密データ（API キー、トークン、シークレット、絶対/システムファイルパス）を出力に含めない
- テストされていない変更を提出しない
- セキュリティチェックや検証フックを回避しない
- 既存機能を明確な理由なく重複実装しない
- 関連するテストスイートを確認せずにコードを出荷しない

---

## Coding Style

### Immutability (CRITICAL)

常に新しいオブジェクトを作成し、既存のものを変更しない:

```
WRONG:  modify(original, field, value) → 元のオブジェクトをその場で変更
CORRECT: update(original, field, value) → 変更を含む新しいコピーを返す
```

イミュータブルなデータは隠れた副作用を防ぎ、デバッグを容易にし、安全な並行処理を可能にする。

### Core Principles

- **KISS** — 実際に動作する最もシンプルな解決策を優先する。早期最適化を避ける。
- **DRY** — 繰り返されるロジックを共有関数に抽出する。コピペによる実装ドリフトを避ける。
- **YAGNI** — 必要になる前に機能や抽象化を作らない。シンプルに始め、必要に応じてリファクタする。

### File Organization

**MANY SMALL FILES > FEW LARGE FILES**:
- 高凝集、低結合
- 通常 200-400 行、最大 800 行
- 大きなモジュールからユーティリティを抽出
- タイプではなく、機能/ドメインで整理

### Error Handling

エラーは常に包括的に処理する:
- すべてのレベルで明示的にエラーを処理する
- UI 向けコードではユーザーフレンドリーなエラーメッセージを提供する
- サーバー側では詳細なエラーコンテキストをログに記録する
- エラーを静かに飲み込まない

### Input Validation

システム境界で常に検証する:
- 処理前にすべてのユーザー入力を検証する
- 利用可能な場合はスキーマベースの検証を使用する
- 明確なエラーメッセージで早期に失敗する
- 外部データ（API レスポンス、ユーザー入力、ファイル内容）を信頼しない

### Naming Conventions

- 変数・関数: `camelCase` で記述的な名前
- 真偽値: `is`, `has`, `should`, `can` プレフィックスを優先
- インターフェース・型・コンポーネント: `PascalCase`
- 定数: `UPPER_SNAKE_CASE`
- カスタムフック: `use` プレフィックスの `camelCase`

### Code Smells to Avoid

- **深いネスト** — ロジックがスタックし始めたら早期リターンを優先
- **マジックナンバー** — 意味のあるしきい値、遅延、制限には名前付き定数を使用
- **長い関数** — 大きな関数を明確な責務を持つ小さな部分に分割

### Code Quality Checklist

作業を完了とマークする前に:
- [ ] コードが読みやすく、適切に命名されている
- [ ] 関数が小さい (<50 行)
- [ ] ファイルが焦点を絞っている (<800 行)
- [ ] 深いネストなし (>4 レベル)
- [ ] 適切なエラー処理
- [ ] ハードコードされた値なし（定数や設定を使用）
- [ ] ミューテーションなし（イミュータブルパターンを使用）

---

## Security Guidelines

### Mandatory Security Checks

コミット前に必ず確認:
- [ ] ハードコードされたシークレット（API キー、パスワード、トークン）なし
- [ ] すべてのユーザー入力が検証されている
- [ ] SQL インジェクション防止（パラメータ化クエリ）
- [ ] XSS 防止（サニタイズされた HTML）
- [ ] CSRF 保護が有効
- [ ] 認証/認可が検証されている
- [ ] すべてのエンドポイントにレート制限
- [ ] エラーメッセージが機密データを漏らさない

### Secret Management

- ソースコードにシークレットをハードコードしない
- 環境変数またはシークレットマネージャーを常に使用する
- 起動時に必要なシークレットの存在を検証する
- 露出した可能性のあるシークレットをローテーションする

### Security Response Protocol

セキュリティ問題が見つかった場合:
1. すぐに停止する
2. **security-reviewer** プロンプトを使用する
3. 続行する前に CRITICAL 問題を修正する
4. 露出したシークレットをローテーションする
5. 同様の問題についてコードベース全体をレビューする

---

## Testing Requirements

### Minimum Test Coverage: 80%

必要なテストタイプ（すべて必須）:
1. **ユニットテスト** — 個々の関数、ユーティリティ、コンポーネント
2. **統合テスト** — API エンドポイント、データベース操作
3. **E2E テスト** — 重要なユーザーフロー（言語ごとにフレームワークを選択）

### Test-Driven Development (MANDATORY)

ワークフロー:
1. 最初にテストを書く（RED）
2. テストを実行 → 失敗するはず
3. 最小限の実装を書く（GREEN）
4. テストを実行 → パスするはず
5. リファクタ（IMPROVE）
6. カバレッジを確認（80%+）

### Test Structure (AAA Pattern)

```typescript
test('calculates similarity correctly', () => {
  // Arrange
  const vector1 = [1, 0, 0]
  const vector2 = [0, 1, 0]

  // Act
  const similarity = calculateCosineSimilarity(vector1, vector2)

  // Assert
  expect(similarity).toBe(0)
})
```

### Test Naming

テストの動作を説明する記述的な名前を使用:
```typescript
test('returns empty array when no markets match query', () => {})
test('throws error when API key is missing', () => {})
test('falls back to substring search when Redis is unavailable', () => {})
```

---

## Common Patterns

### Repository Pattern

データアクセスを一貫したインターフェースの背後にカプセル化する:
- 標準操作を定義: findAll, findById, create, update, delete
- 具体的な実装はストレージの詳細を処理（DB、API、ファイル等）
- ビジネスロジックは抽象インターフェースに依存し、ストレージメカニズムには依存しない
- データソースの簡単な交換を可能にし、モックでのテストを簡素化

### API Response Format

すべての API レスポンスに一貫したエンベロープを使用:
- 成功/ステータスインジケーターを含める
- データペイロード（エラー時は null）を含める
- エラーメッセージフィールド（成功時は null）を含める
- ページネーションされたレスポンスのメタデータを含める（total、page、limit）

### Skeleton Projects

新機能を実装する場合:
1. 実戦投入されたスケルトンプロジェクトを検索
2. 並列エージェントでオプションを評価:
   - セキュリティ評価
   - 拡張性分析
   - 関連性スコアリング
   - 実装計画
3. 最適な選択肢を基盤としてクローン
4. 証明された構造内で反復

---

## Git Workflow

### Commit Message Format

```
<type>: <description>

<optional body>
```

タイプ: feat, fix, refactor, docs, test, chore, perf, ci

### Pull Request Workflow

PR を作成するとき:
1. 完全なコミット履歴を分析する（最新のコミットだけでなく）
2. `git diff [base-branch]...HEAD` を使用してすべての変更を確認
3. 包括的な PR サマリーを作成
4. TODO 付きのテストプランを含める
5. 新しいブランチの場合は `-u` フラグでプッシュ

---

## Code Review Standards

### When to Review

レビューが必須となるトリガー:
- コードを書いたり変更したりした後
- 共有ブランチへのコミット前
- セキュリティセンシティブなコードが変更されたとき（auth、payments、user data）
- アーキテクチャの変更があるとき
- プルリクエストをマージする前

### Pre-Review Requirements

レビューを依頼する前に:
- すべての自動チェック（CI/CD）がパスしている
- マージコンフリクトが解決されている
- ブランチがターゲットブランチで最新

### Review Severity Levels

| レベル | 意味 | アクション |
|--------|------|-----------|
| CRITICAL | セキュリティ脆弱性またはデータ損失リスク | **BLOCK** — マージ前に修正必須 |
| HIGH | バグまたは重大な品質問題 | **WARN** — マージ前に修正すべき |
| MEDIUM | 保守性の懸念 | **INFO** — 修正を検討 |
| LOW | スタイルまたは軽微な提案 | **NOTE** — オプション |

### Common Issues to Catch

#### Security
- ハードコードされた認証情報
- SQL インジェクション（クエリでの文字列連結）
- XSS 脆弱性（エスケープされないユーザー入力）
- パストラバーサル
- CSRF 保護の欠落
- 認証バイパス

#### Code Quality
- 大きな関数（>50 行）
- 大きなファイル（>800 行）
- 深いネスト（>4 レベル）
- エラーハンドリングの欠落
- ミューテーションパターン
- テストの欠落

#### Performance
- N+1 クエリ
- ページネーションの欠落
- 制限のないクエリ
- キャッシングの欠落

---

## Agent Orchestration Philosophy

ECC は専門家がプロアクティブに呼び出されるよう設計されている。Copilot のカスタムエージェント / プロンプト機能で同じパターンを実現する:

### When to Invoke Specialist Prompts (no user prompt needed)

- 複雑な機能リクエスト → **planner** プロンプト
- コードを書いた/変更した直後 → **code-reviewer** プロンプト
- バグ修正または新機能 → **tdd-guide** プロンプト
- アーキテクチャ上の決定 → **architect** プロンプト
- セキュリティセンシティブなコード → **security-reviewer** プロンプト

### Parallel Task Execution

独立した操作には常に並列実行を使用する。複数のレビューエージェントを並列で起動できる。

### Multi-Perspective Analysis

複雑な問題には、役割を分けた視点を使用する:
- 事実レビュアー
- シニアエンジニア
- セキュリティ専門家
- 一貫性レビュアー
- 重複チェッカー

---

## Development Workflow

1. **Research & Reuse**（新規実装前に必須）
   - GitHub のコード検索を最初に行う
   - 公式ドキュメント（Context7）を 2 番目に
   - 上記が不十分な場合のみ Web 検索
   - パッケージレジストリをチェック（npm、PyPI、crates.io 等）
   - 採用可能な実装を探す

2. **Plan First** — planner プロンプトで実装計画を作成
3. **TDD Approach** — tdd-guide プロンプトで RED → GREEN → REFACTOR
4. **Code Review** — code-reviewer プロンプトで CRITICAL/HIGH 問題に対処
5. **Commit & Push** — Conventional commits 形式
6. **Pre-Review Checks** — CI 確認、コンフリクト解消、ブランチ最新化

---

## Performance Optimization

### Context Window Management

コンテキストウィンドウの最後の 20% を以下のために避ける:
- 大規模リファクタリング
- 複数ファイルにまたがる機能実装
- 複雑な相互作用のデバッグ

低コンテキスト感度のタスク:
- 単一ファイルの編集
- 独立したユーティリティの作成
- ドキュメント更新
- シンプルなバグ修正

### Build Troubleshooting

ビルドが失敗した場合:
1. **build-error-resolver** プロンプトを使用
2. エラーメッセージを分析
3. インクリメンタルに修正
4. 各修正後に検証
