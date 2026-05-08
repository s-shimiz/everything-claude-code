---
applyTo: "**/*.{kt,kts}"
---

# Kotlin ルール

> ECC `rules/kotlin/` から派生。

## Formatting

- **ktlint** または **Detekt**
- 公式 Kotlin コードスタイル（`gradle.properties` で `kotlin.code.style=official`）

## Immutability

- `val` を `var` より優先 — デフォルトで `val`、ミューテーションが必要な時のみ `var`
- 値型には `data class`、パブリック API で不変コレクション（`List`, `Map`, `Set`）
- 状態更新には Copy-on-write: `state.copy(field = newValue)`

## Naming

- `camelCase`: 関数、プロパティ
- `PascalCase`: クラス、インターフェース、object、type alias
- `SCREAMING_SNAKE_CASE`: 定数
- インターフェースは `I` プレフィックスではなく振る舞いを示す: `Clickable` not `IClickable`

## Null Safety

- `!!` を使わない — `?.`, `?:`, `requireNotNull()`, `checkNotNull()` を優先
- スコープ付きの null 安全な操作には `?.let {}`

```kotlin
// BAD
val name = user!!.name

// GOOD
val name = user?.name ?: "Unknown"
val name = requireNotNull(user) { "User must be set" }.name
```

## Sealed Types

クローズド状態階層には sealed クラス/インターフェースを使用:

```kotlin
sealed interface UiState<out T> {
    data object Loading : UiState<Nothing>
    data class Success<T>(val data: T) : UiState<T>
    data class Error(val message: String) : UiState<Nothing>
}
```

sealed 型では `when` を網羅的に使い `else` ブランチを書かない。

## Extension Functions

- レシーバ型の名前のファイルに配置（`StringExt.kt`, `FlowExt.kt`）
- `Any` や過度に汎用的な型に拡張を追加しない

## Scope Functions

- `let` — null チェック + 変換: `user?.let { greet(it) }`
- `run` — レシーバを使った計算: `service.run { fetch(config) }`
- `apply` — オブジェクト設定: `builder.apply { timeout = 30 }`
- `also` — 副作用: `result.also { log(it) }`
- 深いネスト（最大 2 レベル）を避ける

## Error Handling

- `Result<T>` またはカスタム sealed 型を使用
- throwable コードのラッピングに `runCatching {}` を使用
- `CancellationException` を catch しない — 必ず再 throw
- 制御フローに try-catch を使用しない

```kotlin
// BAD — 例外を制御フローに
val user = try { repository.getUser(id) } catch (e: NotFoundException) { null }

// GOOD — nullable を返す
val user: User? = repository.findUser(id)
```

## Coroutines

- 構造化された並行性: `coroutineScope { ... }`、`supervisorScope { ... }`
- スコープ外で `Dispatchers.Main` を使用しない
- すべての suspend 関数をテスト可能な dispatcher に注入

## Testing

- **Kotest** + **Kover**（カバレッジ）
- 80% 以上のカバレッジ
