---
applyTo: "**/*.go"
---

# Go ルール

> ECC `rules/golang/` から派生。

## Formatting

- **gofmt** と **goimports** が必須 — スタイル論争なし

## Design Principles

- インターフェースを受け取り、構造体を返す（Accept interfaces, return structs）
- インターフェースを小さく保つ（1〜3 メソッド）

## Error Handling

エラーは常にコンテキスト付きでラップ:

```go
if err != nil {
    return fmt.Errorf("failed to create user: %w", err)
}
```

## Security

```go
apiKey := os.Getenv("OPENAI_API_KEY")
if apiKey == "" {
    log.Fatal("OPENAI_API_KEY not configured")
}
```

セキュリティスキャン:
```bash
gosec ./...
```

## Context & Timeouts

常に `context.Context` でタイムアウト制御:

```go
ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
defer cancel()
```

## Patterns

### Functional Options

```go
type Option func(*Server)

func WithPort(port int) Option {
    return func(s *Server) { s.port = port }
}

func NewServer(opts ...Option) *Server {
    s := &Server{port: 8080}
    for _, opt := range opts {
        opt(s)
    }
    return s
}
```

### Small Interfaces

インターフェースは実装側ではなく使用側で定義する。

### Dependency Injection

コンストラクタ関数で依存性を注入:

```go
func NewUserService(repo UserRepository, logger Logger) *UserService {
    return &UserService{repo: repo, logger: logger}
}
```

## Testing

- 標準 `go test` + **テーブル駆動テスト**
- レース検出: `go test -race ./...`
- カバレッジ: `go test -cover ./...`

```go
func TestAdd(t *testing.T) {
    tests := []struct {
        name string
        a, b int
        want int
    }{
        {"positive", 1, 2, 3},
        {"zero", 0, 0, 0},
        {"negative", -1, 1, 0},
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            if got := Add(tt.a, tt.b); got != tt.want {
                t.Errorf("Add(%d, %d) = %d, want %d", tt.a, tt.b, got, tt.want)
            }
        })
    }
}
```
