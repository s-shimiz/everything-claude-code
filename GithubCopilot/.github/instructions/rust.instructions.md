---
applyTo: "**/*.rs"
---

# Rust ルール

> ECC `rules/rust/` から派生。

## Formatting & Lints

- **rustfmt**: コミット前に必ず `cargo fmt`
- **clippy**: `cargo clippy -- -D warnings`（警告をエラー扱い）
- 4 スペースインデント、最大行幅 100 文字

## Immutability

Rust 変数はデフォルトでイミュータブル — これを活かす:

- デフォルトで `let`、ミューテーションが必要な場合のみ `let mut`
- イン・プレースのミューテーションより新しい値を返すことを優先
- アロケートが必要かどうかわからない場合は `Cow<'_, T>` を使用

```rust
use std::borrow::Cow;

// GOOD — デフォルトでイミュータブル、新しい値を返す
fn normalize(input: &str) -> Cow<'_, str> {
    if input.contains(' ') {
        Cow::Owned(input.replace(' ', "_"))
    } else {
        Cow::Borrowed(input)
    }
}
```

## Naming

- `snake_case`: 関数、メソッド、変数、モジュール、クレート
- `PascalCase`: 型、トレイト、enum、型パラメータ
- `SCREAMING_SNAKE_CASE`: 定数、static
- ライフタイム: 短い小文字（`'a`, `'de`）

## Ownership and Borrowing

- デフォルトで借用（`&T`）、所有権が必要な場合のみ取る
- 根本原因を理解せずにボローチェッカーを満たすために clone しない
- 関数パラメータでは `&str` > `String`、`&[T]` > `Vec<T>`
- コンストラクタが `String` を所有する必要がある場合は `impl Into<String>`

## Error Handling

- `Result<T, E>` と `?` で伝播 — プロダクションコードで `unwrap()` しない
- **ライブラリ**: `thiserror` で型付けされたエラーを定義
- **アプリケーション**: `anyhow` で柔軟なエラーコンテキスト
- `.with_context(|| format!("failed to ..."))?` でコンテキスト追加

```rust
// ライブラリエラー: thiserror
#[derive(Debug, thiserror::Error)]
pub enum ConfigError {
    #[error("failed to read config: {0}")]
    Io(#[from] std::io::Error),
    #[error("invalid config format: {0}")]
    Parse(String),
}

// アプリケーションエラー: anyhow
use anyhow::Context;

fn load_config(path: &str) -> anyhow::Result<Config> {
    let content = std::fs::read_to_string(path)
        .with_context(|| format!("failed to read {path}"))?;
    toml::from_str(&content)
        .with_context(|| format!("failed to parse {path}"))
}
```

## Iterators Over Loops

変換にはイテレータチェーンを優先、複雑な制御フローにはループを使用:

```rust
let active_emails: Vec<&str> = users.iter()
    .filter(|u| u.is_active)
    .map(|u| u.email.as_str())
    .collect();
```

## Module Organization

タイプではなくドメインで整理:

```text
src/
├── main.rs
├── lib.rs
├── auth/           # ドメインモジュール
│   ├── mod.rs
│   ├── token.rs
│   └── middleware.rs
├── orders/
│   ├── mod.rs
│   ├── model.rs
│   └── service.rs
└── db/             # インフラストラクチャ
    └── mod.rs
```

## Visibility

- デフォルトで private、内部共有には `pub(crate)`
- クレートのパブリック API の一部のみ `pub` をマーク
- パブリック API は `lib.rs` から再エクスポート

## Security

```rust
// BAD
const API_KEY: &str = "sk-abc123...";

// GOOD — 環境変数 + 早期検証
fn load_api_key() -> anyhow::Result<String> {
    std::env::var("PAYMENT_API_KEY")
        .context("PAYMENT_API_KEY must be set")
}
```

### SQL Injection 防止

```rust
// BAD
let query = format!("SELECT * FROM users WHERE name = '{name}'");

// GOOD — sqlx パラメータ化クエリ
sqlx::query("SELECT * FROM users WHERE name = $1")
    .bind(&name)
    .fetch_one(&pool)
    .await?;
```

### Parse, Don't Validate

型システムで不変条件を強制（newtype パターン）:

```rust
pub struct Email(String);

impl Email {
    pub fn parse(input: &str) -> Result<Self, ValidationError> {
        // 検証ロジック…
        Ok(Self(input.trim().to_string()))
    }
    pub fn as_str(&self) -> &str { &self.0 }
}
```

### Unsafe Code

- `unsafe` ブロックを最小化
- すべての `unsafe` ブロックには `// SAFETY:` コメントで不変条件を説明
- 利便性のために `unsafe` でボローチェッカーを回避しない

### Dependency Security

```bash
cargo audit            # CVE スキャン
cargo deny check       # ライセンス・アドバイザリチェック
```

## Testing

- `#[test]` + `#[cfg(test)]` でユニットテスト
- **rstest**: パラメータ化テスト
- **proptest**: プロパティベーステスト
- **mockall**: トレイトベースのモック
- `#[tokio::test]`: async テスト

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn creates_user_with_valid_email() {
        let user = User::new("Alice", "alice@example.com").unwrap();
        assert_eq!(user.name, "Alice");
    }
}
```

## Patterns

### Repository (Trait)

```rust
pub trait OrderRepository: Send + Sync {
    fn find_by_id(&self, id: u64) -> Result<Option<Order>, StorageError>;
    fn save(&self, order: &Order) -> Result<Order, StorageError>;
    fn delete(&self, id: u64) -> Result<(), StorageError>;
}
```

### Newtype for Type Safety

```rust
struct UserId(u64);
struct OrderId(u64);

// UserId と OrderId を取り違えない
fn get_order(user: UserId, order: OrderId) -> anyhow::Result<Order> { todo!() }
```

### Enum State Machines

不正な状態を表現不可能にする:

```rust
enum ConnectionState {
    Disconnected,
    Connecting { attempt: u32 },
    Connected { session_id: String },
    Failed { reason: String, retries: u32 },
}
```

ビジネスクリティカルな enum でワイルドカード `_` を使わず、常に網羅的にマッチ。
