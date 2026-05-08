---
name: api-design
description: REST API design patterns including resource naming, status codes, pagination, filtering, error responses, versioning, and rate limiting for production APIs.
---

# API Design Patterns

一貫性があり、開発者フレンドリーな REST API を設計するための規約とベストプラクティス。

## When to Activate

- 新しい API エンドポイントの設計
- 既存 API 契約のレビュー
- ページネーション、フィルタリング、ソートの追加
- API のエラー処理実装
- API バージョニング戦略の計画
- パブリックまたはパートナー向け API の構築

## Resource Design

### URL Structure

```
GET    /api/v1/users
GET    /api/v1/users/:id
POST   /api/v1/users
PUT    /api/v1/users/:id
PATCH  /api/v1/users/:id
DELETE /api/v1/users/:id

# サブリソース
GET    /api/v1/users/:id/orders
POST   /api/v1/users/:id/orders

# CRUD 以外のアクション（動詞は控えめに）
POST   /api/v1/orders/:id/cancel
POST   /api/v1/auth/login
```

### Naming Rules

```
# GOOD
/api/v1/team-members          # kebab-case 複数語
/api/v1/orders?status=active  # フィルタリングはクエリパラメータ
/api/v1/users/123/orders      # 所有関係のネストリソース

# BAD
/api/v1/getUsers              # URL に動詞
/api/v1/user                  # 単数形（複数を使う）
/api/v1/team_members          # snake_case
```

## HTTP Status Codes

```
# Success
200 OK         — GET, PUT, PATCH（レスポンスボディ付き）
201 Created    — POST（Location ヘッダー含む）
204 No Content — DELETE, PUT（レスポンスボディなし）

# Client Errors
400 Bad Request          — 検証失敗、不正な JSON
401 Unauthorized         — 認証なしまたは無効
403 Forbidden            — 認証済みだが認可なし
404 Not Found
409 Conflict             — 重複、状態競合
422 Unprocessable Entity — 意味的に無効
429 Too Many Requests    — レート制限超過

# Server Errors
500 Internal Server Error — 予期しない失敗（詳細を露出しない）
502 Bad Gateway
503 Service Unavailable   — Retry-After ヘッダー
```

## Response Format

### Success Response

```json
{
  "data": {
    "id": "abc-123",
    "email": "alice@example.com",
    "name": "Alice",
    "created_at": "2025-01-15T10:30:00Z"
  }
}
```

### Collection with Pagination

```json
{
  "data": [...],
  "meta": {
    "total": 142,
    "page": 1,
    "per_page": 20,
    "total_pages": 8
  },
  "links": {
    "self": "/api/v1/users?page=1",
    "next": "/api/v1/users?page=2",
    "last": "/api/v1/users?page=8"
  }
}
```

### Error Response

```json
{
  "error": {
    "code": "validation_error",
    "message": "Request validation failed",
    "details": [
      { "field": "email", "message": "Must be valid email", "code": "invalid_format" },
      { "field": "age", "message": "Must be between 0 and 150", "code": "out_of_range" }
    ]
  }
}
```

## Pagination

### Offset-Based

```
GET /api/v1/users?page=2&per_page=20
```

### Cursor-Based（高性能、推奨）

```
GET /api/v1/users?cursor=eyJpZCI6IjEyMyJ9&limit=20

レスポンス:
{
  "data": [...],
  "meta": {
    "next_cursor": "eyJpZCI6IjE0MyJ9",
    "has_more": true
  }
}
```

## Filtering & Sorting

```
# フィルタリング
GET /api/v1/orders?status=active&created_after=2025-01-01

# ソート（複数フィールド）
GET /api/v1/users?sort=-created_at,name

# 検索
GET /api/v1/users?q=alice

# フィールド選択
GET /api/v1/users?fields=id,name,email
```

## Versioning

URI バージョニング（推奨）:
```
/api/v1/users
/api/v2/users
```

ヘッダーバージョニング:
```
Accept: application/vnd.example.v2+json
```

## Rate Limiting

レスポンスヘッダー:
```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 987
X-RateLimit-Reset: 1640995200
Retry-After: 60
```

429 レスポンス:
```json
{
  "error": {
    "code": "rate_limit_exceeded",
    "message": "Rate limit exceeded. Try again in 60 seconds."
  }
}
```

## Authentication

Bearer トークン:
```
Authorization: Bearer eyJhbGc...
```

API キー（シンプル）:
```
X-API-Key: sk_live_abc123...
```

## Idempotency

POST リクエストの冪等性:
```
POST /api/v1/payments
Idempotency-Key: abc-123-unique-uuid

# 同じキーでの繰り返しリクエストは同じレスポンス
```

## CORS

```typescript
// 適切な CORS 設定
{
  origin: ['https://app.example.com'],
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true,
  maxAge: 86400
}
```

## Documentation

OpenAPI/Swagger でドキュメント化:
- すべてのエンドポイントを文書化
- リクエスト / レスポンススキーマ
- 例リクエスト / レスポンス
- 認証要件
- エラーコード
