---
applyTo: "**/*.{ts,tsx,js,jsx,mjs,cjs}"
---

# TypeScript / JavaScript ルール

> ECC `rules/typescript/` から派生。`.github/copilot-instructions.md` の共通ルールを継承して TS/JS 固有の指針を追加。

## Types and Interfaces

### Public APIs

- エクスポートされた関数、共有ユーティリティ、パブリッククラスメソッドにパラメータと戻り値の型を追加する
- TypeScript に明白なローカル変数の型を推論させる
- 繰り返されるインライン型を名前付き型 / インターフェースに抽出する

```typescript
// WRONG: 明示的な型のないエクスポート関数
export function formatUser(user) {
  return `${user.firstName} ${user.lastName}`
}

// CORRECT: パブリック API に明示的な型
interface User {
  firstName: string
  lastName: string
}

export function formatUser(user: User): string {
  return `${user.firstName} ${user.lastName}`
}
```

### Interfaces vs. Type Aliases

- 拡張または実装される可能性があるオブジェクト形状には `interface` を使用
- ユニオン、交差、タプル、マップ型、ユーティリティ型には `type` を使用
- 相互運用性が必要でない限り、`enum` よりも文字列リテラルユニオンを優先

```typescript
interface User {
  id: string
  email: string
}

type UserRole = 'admin' | 'member'
type UserWithRole = User & {
  role: UserRole
}
```

### Avoid `any`

- アプリケーションコードで `any` を避ける
- 外部または信頼できない入力には `unknown` を使用し、安全にナローイング
- 値の型が呼び出し元に依存する場合はジェネリクスを使用

```typescript
// WRONG: any は型安全性を削除
function getErrorMessage(error: any) {
  return error.message
}

// CORRECT: unknown は安全なナローイングを強制
function getErrorMessage(error: unknown): string {
  if (error instanceof Error) {
    return error.message
  }
  return 'Unexpected error'
}
```

### React Props

- 名前付き `interface` または `type` でコンポーネント props を定義
- コールバック props を明示的に型付け
- 特定の理由がない限り `React.FC` を使用しない

```typescript
interface UserCardProps {
  user: User
  onSelect: (id: string) => void
}

function UserCard({ user, onSelect }: UserCardProps) {
  return <button onClick={() => onSelect(user.id)}>{user.email}</button>
}
```

## Immutability

スプレッド演算子でイミュータブルな更新:

```typescript
// WRONG: ミューテーション
function updateUser(user: User, name: string): User {
  user.name = name // MUTATION!
  return user
}

// CORRECT: イミュータビリティ
function updateUser(user: Readonly<User>, name: string): User {
  return {
    ...user,
    name
  }
}
```

## Error Handling

async/await + try-catch、unknown エラーを安全にナローイング:

```typescript
async function loadUser(userId: string): Promise<User> {
  try {
    const result = await riskyOperation(userId)
    return result
  } catch (error: unknown) {
    logger.error('Operation failed', error)
    throw new Error(getErrorMessage(error))
  }
}
```

## Input Validation

Zod でスキーマベースの検証を行い、スキーマから型を推論:

```typescript
import { z } from 'zod'

const userSchema = z.object({
  email: z.string().email(),
  age: z.number().int().min(0).max(150)
})

type UserInput = z.infer<typeof userSchema>
const validated: UserInput = userSchema.parse(input)
```

## Console.log

- プロダクションコードに `console.log` ステートメントを残さない
- 適切なロギングライブラリ（pino, winston 等）を使用する

## Security

```typescript
// NEVER: ハードコードされたシークレット
const apiKey = "sk-proj-xxxxx"

// ALWAYS: 環境変数
const apiKey = process.env.OPENAI_API_KEY
if (!apiKey) {
  throw new Error('OPENAI_API_KEY not configured')
}
```

## Testing

E2E テストは **Playwright** を使用。重要なユーザーフローをカバー。

## Patterns

### API Response Format

```typescript
interface ApiResponse<T> {
  success: boolean
  data?: T
  error?: string
  meta?: {
    total: number
    page: number
    limit: number
  }
}
```

### Repository Pattern

```typescript
interface Repository<T> {
  findAll(filters?: Filters): Promise<T[]>
  findById(id: string): Promise<T | null>
  create(data: CreateDto): Promise<T>
  update(id: string, data: UpdateDto): Promise<T>
  delete(id: string): Promise<void>
}
```

### Custom Hook Pattern

```typescript
export function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState<T>(value)

  useEffect(() => {
    const handler = setTimeout(() => setDebouncedValue(value), delay)
    return () => clearTimeout(handler)
  }, [value, delay])

  return debouncedValue
}
```
