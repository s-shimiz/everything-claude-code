---
name: security-review
description: Use this skill when adding authentication, handling user input, working with secrets, creating API endpoints, or implementing payment/sensitive features. Provides comprehensive security checklist and patterns.
---

# Security Review Skill

このスキルは、すべてのコードがセキュリティのベストプラクティスに従い、潜在的な脆弱性を特定することを保証する。

## When to Activate

- 認証または認可の実装
- ユーザー入力またはファイルアップロードの処理
- 新しい API エンドポイントの作成
- シークレットまたは認証情報の操作
- 決済機能の実装
- 機密データの保存または送信
- サードパーティ API の統合

## Security Checklist

### 1. Secrets Management

```typescript
// FAIL: NEVER
const apiKey = "sk-proj-xxxxx"
const dbPassword = "password123"

// PASS: ALWAYS
const apiKey = process.env.OPENAI_API_KEY
if (!apiKey) {
  throw new Error('OPENAI_API_KEY not configured')
}
```

検証:
- [ ] ハードコードされた API キー、トークン、パスワードなし
- [ ] すべてのシークレットが環境変数
- [ ] `.env.local` が `.gitignore` に
- [ ] git 履歴にシークレットなし
- [ ] 本番シークレットはホスティングプラットフォーム（Vercel、Railway）に

### 2. Input Validation

```typescript
import { z } from 'zod'

const CreateUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(1).max(100),
  age: z.number().int().min(0).max(150)
})

export async function createUser(input: unknown) {
  try {
    const validated = CreateUserSchema.parse(input)
    return await db.users.create(validated)
  } catch (error) {
    if (error instanceof z.ZodError) {
      return { success: false, errors: error.errors }
    }
    throw error
  }
}
```

ファイルアップロード検証:
```typescript
function validateFileUpload(file: File) {
  const maxSize = 5 * 1024 * 1024  // 5MB
  if (file.size > maxSize) throw new Error('File too large')

  const allowedTypes = ['image/jpeg', 'image/png', 'image/gif']
  if (!allowedTypes.includes(file.type)) throw new Error('Invalid type')

  const allowedExt = ['.jpg', '.jpeg', '.png', '.gif']
  const ext = file.name.toLowerCase().match(/\.[^.]+$/)?.[0]
  if (!ext || !allowedExt.includes(ext)) throw new Error('Invalid extension')
}
```

### 3. SQL Injection Prevention

```typescript
// FAIL: NEVER concatenate
const query = `SELECT * FROM users WHERE email = '${userEmail}'`

// PASS: ALWAYS parameterize
const { data } = await supabase.from('users').select('*').eq('email', userEmail)
await db.query('SELECT * FROM users WHERE email = $1', [userEmail])
```

### 4. Authentication & Authorization

JWT トークン処理:
```typescript
// FAIL: localStorage（XSS に脆弱）
localStorage.setItem('token', token)

// PASS: httpOnly cookies
res.setHeader('Set-Cookie',
  `token=${token}; HttpOnly; Secure; SameSite=Strict; Max-Age=3600`)
```

認可チェック:
```typescript
export async function deleteUser(userId: string, requesterId: string) {
  const requester = await db.users.findUnique({ where: { id: requesterId } })
  if (requester.role !== 'admin') {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 403 })
  }
  await db.users.delete({ where: { id: userId } })
}
```

Row Level Security (Supabase):
```sql
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users view own data"
  ON users FOR SELECT
  USING (auth.uid() = id);
```

### 5. XSS Prevention

```typescript
import DOMPurify from 'isomorphic-dompurify'

function renderUserContent(html: string) {
  const clean = DOMPurify.sanitize(html, {
    ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'p'],
    ALLOWED_ATTR: []
  })
  return <div dangerouslySetInnerHTML={{ __html: clean }} />
}
```

CSP ヘッダー:
```typescript
// next.config.js
const headers = [{
  key: 'Content-Security-Policy',
  value: `default-src 'self'; script-src 'self' 'unsafe-inline'; ...`
}]
```

### 6. CSRF Protection

```typescript
export async function POST(request: Request) {
  const token = request.headers.get('X-CSRF-Token')
  if (!csrf.verify(token)) {
    return NextResponse.json({ error: 'Invalid CSRF token' }, { status: 403 })
  }
}
```

### 7. Rate Limiting

```typescript
import rateLimit from 'express-rate-limit'

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  message: 'Too many requests'
})

const searchLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: 10
})
```

### 8. Sensitive Data Exposure

- エラーメッセージで内部情報を漏らさない
- ログでシークレットをマスク
- 機密データは送信中も保管中も暗号化
- レスポンスから不要なフィールドを除外

## OWASP Top 10 Reference

1. **Broken Access Control** — 認可チェックを徹底
2. **Cryptographic Failures** — bcrypt/Argon2、TLS、暗号化
3. **Injection** — パラメータ化クエリ、入力サニタイズ
4. **Insecure Design** — 脅威モデリング、セキュアデフォルト
5. **Security Misconfiguration** — デフォルト認証情報変更、不要機能無効化
6. **Vulnerable Components** — `npm audit`、Snyk、Dependabot
7. **Identification and Authentication Failures** — MFA、セッション管理
8. **Software and Data Integrity Failures** — SRI、署名検証
9. **Security Logging Failures** — セキュリティイベントログ、アラート
10. **Server-Side Request Forgery (SSRF)** — URL ホワイトリスト検証
