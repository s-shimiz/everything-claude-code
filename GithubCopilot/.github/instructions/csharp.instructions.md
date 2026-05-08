---
applyTo: "**/*.{cs,csx}"
---

# C# ルール

> ECC `rules/csharp/` から派生。

## Standards

- 現在の .NET 規約に従う、nullable 参照型を有効化
- パブリック / 内部 API には明示的なアクセス修飾子を優先
- ファイルは主要な型と一致させる

## Types and Models

- 不変値型には `record` または `record struct` を優先
- ID とライフサイクルを持つエンティティには `class`
- サービス境界と抽象化には `interface`
- アプリケーションコードで `dynamic` を避ける

```csharp
public sealed record UserDto(Guid Id, string Email);

public interface IUserRepository
{
    Task<UserDto?> FindByIdAsync(Guid id, CancellationToken cancellationToken);
}
```

## Immutability

- `init` セッター、コンストラクタパラメータ、不変コレクションを優先
- 入力モデルをインプレースで変更しない

```csharp
public sealed record UserProfile(string Name, string Email);

public static UserProfile Rename(UserProfile profile, string name) =>
    profile with { Name = name };
```

## Async and Error Handling

- `.Result` や `.Wait()` のブロッキング呼び出しより `async`/`await`
- パブリック async API を通して `CancellationToken` を渡す
- 特定の例外をスローし、構造化プロパティでログ

```csharp
public async Task<Order> LoadOrderAsync(
    Guid orderId,
    CancellationToken cancellationToken)
{
    try
    {
        return await repository.FindAsync(orderId, cancellationToken)
            ?? throw new InvalidOperationException($"Order {orderId} was not found.");
    }
    catch (Exception ex)
    {
        logger.LogError(ex, "Failed to load order {OrderId}", orderId);
        throw;
    }
}
```

## Formatting

- フォーマットとアナライザ修正に `dotnet format`
- `using` ディレクティブを整理し、未使用のインポートを削除
- 読みやすい場合のみ式形式メンバを使用

## Testing

- **xUnit** または **NUnit** + **Moq** + **FluentAssertions**
- 80% 以上のカバレッジ
- `dotnet test --collect:"XPlat Code Coverage"`
