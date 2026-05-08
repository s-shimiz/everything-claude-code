---
applyTo: "**/*.java"
---

# Java ルール

> ECC `rules/java/` から派生。

## Formatting

- **google-java-format** または **Checkstyle**
- 1 ファイル 1 パブリックトップレベル型
- メンバー順: 定数、フィールド、コンストラクタ、public、protected、private

## Immutability

- 値型には `record` を優先（Java 16+）
- フィールドはデフォルトで `final`
- パブリック API から防御的コピーを返す: `List.copyOf()`, `Map.copyOf()`, `Set.copyOf()`

```java
// 不変な値型
public record OrderSummary(Long id, String customerName, BigDecimal total) {}

public class Order {
    private final Long id;
    private final List<LineItem> items;
    public List<LineItem> getItems() {
        return List.copyOf(items);
    }
}
```

## Naming

- `PascalCase`: クラス、インターフェース、record、enum
- `camelCase`: メソッド、フィールド、パラメータ、ローカル変数
- `SCREAMING_SNAKE_CASE`: `static final` 定数
- パッケージ: 全小文字、逆ドメイン

## Modern Java Features

- Records（DTO・値型）— Java 16+
- Sealed classes — Java 17+
- `instanceof` パターンマッチ — Java 16+
- Text blocks — Java 15+
- Switch expressions（アロー構文）— Java 14+
- Switch のパターンマッチ — Java 21+

```java
String label = switch (status) {
    case ACTIVE -> "Active";
    case SUSPENDED -> "Suspended";
    case CLOSED -> "Closed";
};
```

## Optional Usage

- 結果がない可能性のある finder メソッドから `Optional<T>` を返す
- `map()`, `flatMap()`, `orElseThrow()` を使用、`isPresent()` なしの `get()` を呼ばない
- `Optional` をフィールドや引数の型に使用しない

## Error Handling

- ドメインエラーには非チェック例外を優先
- `RuntimeException` を継承するドメイン固有例外を作成
- トップレベル以外で `catch (Exception e)` を避ける

## Security

```java
// BAD
private static final String API_KEY = "sk-abc123...";

// GOOD
String apiKey = System.getenv("PAYMENT_API_KEY");
Objects.requireNonNull(apiKey, "PAYMENT_API_KEY must be set");
```

### SQL Injection 防止

```java
// BAD
String sql = "SELECT * FROM orders WHERE name = '" + name + "'";

// GOOD
PreparedStatement ps = conn.prepareStatement("SELECT * FROM orders WHERE name = ?");
ps.setString(1, name);
```

### Dependency Security

- `mvn dependency:tree` または `./gradlew dependencies` でツリーを確認
- OWASP Dependency-Check または Snyk で CVE スキャン

### Error Messages

- API レスポンスにスタックトレース・内部パス・SQL エラーを露出しない
- ハンドラ境界で例外を安全な汎用クライアントメッセージにマッピング

## Testing

- **JUnit 5** + **AssertJ** + **Mockito** + **Testcontainers**
- パッケージ構造を `src/main/java` と `src/test/java` でミラー
- 80% 以上のカバレッジ

```java
@ExtendWith(MockitoExtension.class)
class OrderServiceTest {
    @Mock private OrderRepository orderRepository;
    private OrderService orderService;

    @BeforeEach
    void setUp() { orderService = new OrderService(orderRepository); }

    @Test
    @DisplayName("findById returns order when exists")
    void findById_existingOrder_returnsOrder() {
        var order = new Order(1L, "Alice", BigDecimal.TEN);
        when(orderRepository.findById(1L)).thenReturn(Optional.of(order));
        var result = orderService.findById(1L);
        assertThat(result.customerName()).isEqualTo("Alice");
    }
}
```

## Patterns

### Repository

```java
public interface OrderRepository {
    Optional<Order> findById(Long id);
    List<Order> findAll();
    Order save(Order order);
    void deleteById(Long id);
}
```

### Constructor Injection（必須）

```java
// GOOD — テスト可能、不変
public class NotificationService {
    private final EmailSender emailSender;
    public NotificationService(EmailSender emailSender) {
        this.emailSender = emailSender;
    }
}

// BAD — フィールドインジェクション
public class NotificationService {
    @Inject private EmailSender emailSender;  // ✗
}
```
