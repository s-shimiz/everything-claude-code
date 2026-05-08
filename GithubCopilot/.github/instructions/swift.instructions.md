---
applyTo: "**/*.swift"
---

# Swift ルール

> ECC `rules/swift/` から派生。

## Formatting

- **SwiftFormat** で自動フォーマット、**SwiftLint** でスタイル強制
- Xcode 16+ では `swift-format` も利用可

## Immutability

- `let` を `var` より優先 — すべて `let` で定義し、コンパイラが要求した時のみ `var`
- 値セマンティクスのために `struct` を優先、ID または参照セマンティクスが必要な場合のみ `class`

## Naming

[Apple API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/) に従う:

- 使用時点での明確さ — 不要な単語を省略
- メソッドとプロパティを役割で命名（型ではなく）
- グローバル定数より `static let`

## Error Handling

Typed throws（Swift 6+）とパターンマッチを使用:

```swift
func load(id: String) throws(LoadError) -> Item {
    guard let data = try? read(from: path) else {
        throw .fileNotFound(id)
    }
    return try decode(data)
}
```

## Concurrency

Swift 6 strict concurrency checking を有効化:

- 分離境界を超えるデータには `Sendable` 値型
- 共有可変状態には actor
- 非構造化 `Task {}` より構造化並行性（`async let`, `TaskGroup`）

## Patterns

### Protocol Witness

プロトコル + 実装の代わりに、関数を保持する struct で柔軟な依存性注入:

```swift
struct UserService {
    var fetchUser: (UUID) async throws -> User
    var saveUser: (User) async throws -> Void
}

// テスト用
let mockService = UserService(
    fetchUser: { _ in .mock },
    saveUser: { _ in }
)
```

## Testing

- **XCTest** または **Swift Testing**（Swift 6+）
- 80% 以上のカバレッジ
- `xcodebuild test -enableCodeCoverage YES`
