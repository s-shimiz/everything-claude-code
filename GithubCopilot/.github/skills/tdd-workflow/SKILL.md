---
name: tdd-workflow
description: Use this skill when writing new features, fixing bugs, or refactoring code. Enforces test-driven development with 80%+ coverage including unit, integration, and E2E tests.
---

# Test-Driven Development Workflow

This skill ensures all code development follows TDD principles with comprehensive test coverage.

## When to Activate

- Writing new features or functionality
- Fixing bugs or issues
- Refactoring existing code
- Adding API endpoints
- Creating new components

## Core Principles

### 1. Tests BEFORE Code
ALWAYS write tests first, then implement code to make tests pass.

### 2. Coverage Requirements
- Minimum 80% coverage (unit + integration + E2E)
- All edge cases covered
- Error scenarios tested
- Boundary conditions verified

### 3. Test Types

#### Unit Tests
- Individual functions and utilities
- Component logic
- Pure functions
- Helpers and utilities

#### Integration Tests
- API endpoints
- Database operations
- Service interactions
- External API calls

#### E2E Tests (Playwright)
- Critical user flows
- Complete workflows
- Browser automation
- UI interactions

## TDD Workflow Steps

### Step 1: Write User Journeys

```
As a [role], I want to [action], so that [benefit]
```

### Step 2: Generate Test Cases

各ユーザージャーニーに対して包括的なテストケースを作成:

```typescript
describe('Feature', () => {
  it('handles happy path', async () => {})
  it('handles empty input gracefully', async () => {})
  it('falls back when service unavailable', async () => {})
  it('returns sorted results', async () => {})
})
```

### Step 3: Run Tests (They Should Fail) — RED

```bash
npm test
# テストは失敗するはず — 実装していない
```

これは必須ステップで、すべてのプロダクション変更に対する RED ゲート。

### Step 4: Implement Code

最小限のコードでテストをパス:

```typescript
export async function feature(input: string) {
  // 実装
}
```

### Step 5: Run Tests Again — GREEN

```bash
npm test
# テストはパスするはず
```

### Step 6: Refactor

テストをグリーンに保ちながらコード品質を改善:
- 重複削除
- 命名改善
- パフォーマンス最適化
- 可読性向上

### Step 7: Verify Coverage

```bash
npm run test:coverage
# 80%+ カバレッジ達成を検証
```

## Testing Patterns

### Unit Test Pattern (Jest/Vitest)

```typescript
import { render, screen, fireEvent } from '@testing-library/react'
import { Button } from './Button'

describe('Button Component', () => {
  it('renders with correct text', () => {
    render(<Button>Click me</Button>)
    expect(screen.getByText('Click me')).toBeInTheDocument()
  })

  it('calls onClick when clicked', () => {
    const handleClick = jest.fn()
    render(<Button onClick={handleClick}>Click</Button>)
    fireEvent.click(screen.getByRole('button'))
    expect(handleClick).toHaveBeenCalledTimes(1)
  })
})
```

### API Integration Test Pattern

```typescript
describe('GET /api/markets', () => {
  it('returns markets successfully', async () => {
    const response = await GET(request)
    expect(response.status).toBe(200)
  })

  it('validates query parameters', async () => {
    const response = await GET(invalidRequest)
    expect(response.status).toBe(400)
  })
})
```

### E2E Test Pattern (Playwright)

```typescript
test('user can search and filter', async ({ page }) => {
  await page.goto('/')
  await page.fill('input[placeholder="Search"]', 'query')
  await page.waitForTimeout(600)
  const results = page.locator('[data-testid="result-card"]')
  await expect(results).toHaveCount(5, { timeout: 5000 })
})
```

## Edge Cases You MUST Test

1. Null/Undefined input
2. Empty arrays/strings
3. Invalid types
4. Boundary values (min/max)
5. Error paths (network failures, DB errors)
6. Race conditions (concurrent operations)
7. Large data (10k+ items)
8. Special characters (Unicode, emojis, SQL chars)

## Anti-Patterns to Avoid

- 動作ではなく実装詳細をテスト
- テストが互いに依存（共有状態）
- アサートが少なすぎる
- 外部依存をモックしない

## Quality Checklist

- [ ] すべてのパブリック関数にユニットテストがある
- [ ] すべての API エンドポイントに統合テストがある
- [ ] 重要なユーザーフローに E2E テストがある
- [ ] エッジケースをカバー（null、empty、invalid）
- [ ] エラーパスをテスト
- [ ] 外部依存にモックを使用
- [ ] テストは独立
- [ ] アサートは具体的で意味がある
- [ ] カバレッジは 80%+
