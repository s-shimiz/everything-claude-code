---
name: coding-standards
description: Baseline cross-project coding conventions for naming, readability, immutability, and code-quality review. Use detailed frontend or backend skills for framework-specific patterns.
---

# Coding Standards & Best Practices

プロジェクト全体に適用可能なベースラインコーディング規約。

このスキルは共有のフロアであり、詳細なフレームワークプレイブックではない。

## When to Activate

- 新しいプロジェクトまたはモジュールの開始
- 品質と保守性のためのコードレビュー
- 規約に従うために既存コードのリファクタリング
- 命名、フォーマット、または構造の一貫性強制
- リント、フォーマット、または型チェックルールのセットアップ
- 新しい貢献者をコーディング規約にオンボード

## Code Quality Principles

### 1. Readability First
- コードは書かれるより読まれる
- 明確な変数名と関数名
- 自己文書化されたコードがコメントよりも好ましい
- 一貫したフォーマット

### 2. KISS (Keep It Simple, Stupid)
- 動作する最もシンプルな解決策
- 過剰設計を避ける
- 早期最適化なし
- 理解しやすい > 賢いコード

### 3. DRY (Don't Repeat Yourself)
- 共通ロジックを関数に抽出
- 再利用可能なコンポーネント作成
- モジュール間でユーティリティを共有
- コピペプログラミングを避ける

### 4. YAGNI (You Aren't Gonna Need It)
- 必要になる前に機能を構築しない
- 投機的汎化を避ける
- 必要時のみ複雑度を追加
- シンプルに始め、必要時にリファクタ

## Naming

```typescript
// PASS: 記述的な名前
const marketSearchQuery = 'election'
const isUserAuthenticated = true
const totalRevenue = 1000

// FAIL: 不明確
const q = 'election'
const flag = true
const x = 1000
```

```typescript
// PASS: 動詞-名詞パターン
async function fetchMarketData(marketId: string) { }
function calculateSimilarity(a: number[], b: number[]) { }
function isValidEmail(email: string): boolean { }

// FAIL: 名詞のみ
async function market(id: string) { }
function similarity(a, b) { }
```

## Immutability (CRITICAL)

```typescript
// PASS: 常にスプレッド演算子
const updatedUser = { ...user, name: 'New Name' }
const updatedArray = [...items, newItem]

// FAIL: 直接ミューテートしない
user.name = 'New Name'  // BAD
items.push(newItem)     // BAD
```

## Error Handling

```typescript
// PASS: 包括的
async function fetchData(url: string) {
  try {
    const response = await fetch(url)
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`)
    }
    return await response.json()
  } catch (error) {
    console.error('Fetch failed:', error)
    throw new Error('Failed to fetch data')
  }
}

// FAIL: エラー処理なし
async function fetchData(url) {
  const response = await fetch(url)
  return response.json()
}
```

## Async/Await Best Practices

```typescript
// PASS: 並列実行
const [users, markets, stats] = await Promise.all([
  fetchUsers(),
  fetchMarkets(),
  fetchStats()
])

// FAIL: 不必要な順次実行
const users = await fetchUsers()
const markets = await fetchMarkets()
const stats = await fetchStats()
```

## Type Safety

```typescript
// PASS: 適切な型
interface Market {
  id: string
  name: string
  status: 'active' | 'resolved' | 'closed'
  created_at: Date
}

function getMarket(id: string): Promise<Market> { }

// FAIL: any を使用
function getMarket(id: any): Promise<any> { }
```

## File Organization

**MANY SMALL FILES > FEW LARGE FILES**:

- 高凝集、低結合
- 200-400 行が典型、最大 800 行
- 大きなモジュールからユーティリティを抽出
- タイプではなく機能 / ドメインで整理

## Code Smells to Avoid

### Deep Nesting
ロジックがスタックし始めたら早期リターンを優先。

### Magic Numbers
意味のあるしきい値、遅延、制限には名前付き定数を使用。

### Long Functions
大きな関数を明確な責務を持つ小さな部分に分割。

## Code Quality Checklist

完了とマークする前に:
- [ ] コードが読みやすく適切に命名されている
- [ ] 関数が小さい (<50 行)
- [ ] ファイルが焦点を絞っている (<800 行)
- [ ] 深いネストなし (>4 レベル)
- [ ] 適切なエラー処理
- [ ] ハードコードされた値なし
- [ ] ミューテーションなし
