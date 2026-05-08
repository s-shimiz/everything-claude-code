---
description: カバレッジを分析し、ギャップを特定し、ターゲットしきい値（80%+）に向けて欠落しているテストを生成。
---

# /test-coverage — Test Coverage

テストカバレッジを分析し、ギャップを特定し、80%+ カバレッジに到達するために欠落しているテストを生成する。

## Step 1: テストフレームワーク検出

| インジケータ | カバレッジコマンド |
|-----------|-----------------|
| `jest.config.*` または `package.json` jest | `npx jest --coverage --coverageReporters=json-summary` |
| `vitest.config.*` | `npx vitest run --coverage` |
| `pytest.ini` / `pyproject.toml` pytest | `pytest --cov=src --cov-report=json` |
| `Cargo.toml` | `cargo llvm-cov --json` |
| `pom.xml` JaCoCo | `mvn test jacoco:report` |
| `go.mod` | `go test -coverprofile=coverage.out ./...` |

## Step 2: カバレッジレポート分析

1. カバレッジコマンド実行
2. 出力を解析（JSON サマリーまたはターミナル出力）
3. **80% 未満カバレッジ**のファイルをリスト、最低から順
4. 各カバレッジ不足ファイルについて特定:
   - テストされていない関数 / メソッド
   - ブランチカバレッジ欠落（if/else、switch、エラーパス）
   - 分母を膨らませているデッドコード

## Step 3: 欠落テスト生成

各カバレッジ不足ファイルについて、優先順位に従ってテスト生成:

1. **ハッピーパス** — 有効入力でのコア機能
2. **エラー処理** — 無効入力、データ欠落、ネットワーク失敗
3. **エッジケース** — 空配列、null/undefined、境界値（0、-1、MAX_INT）
4. **ブランチカバレッジ** — 各 if/else、switch case、ternary

### テスト生成ルール

- ソースに隣接してテスト配置: `foo.ts` → `foo.test.ts`（またはプロジェクト規約）
- プロジェクトの既存テストパターンを使用（import スタイル、アサーションライブラリ、モック方法）
- 外部依存関係をモック（DB、API、ファイルシステム）
- 各テストは独立 — テスト間で共有可変状態なし
- テストを記述的に命名: `test_create_user_with_duplicate_email_returns_409`

## Step 4: 検証

1. フルテストスイート実行 — すべてのテストがパスする必要
2. カバレッジ再実行 — 改善を検証
3. 80%+ に到達したらコミット
