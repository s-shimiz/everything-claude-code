---
applyTo: "**/*.php"
---

# PHP ルール

> ECC `rules/php/` から派生。

## Standards

- **PSR-12** フォーマットと命名規則に従う
- アプリケーションコードで `declare(strict_types=1);` を優先
- 新しいコードでは型ヒント、戻り値型、型付きプロパティを常に使用

## Immutability

- サービス境界を越えるデータには不変 DTO と値オブジェクトを優先
- リクエスト / レスポンスペイロードに `readonly` プロパティまたは不変コンストラクタ
- シンプルなマップには配列を保持、ビジネスクリティカルな構造は明示的なクラスへ

```php
final class UserDto
{
    public function __construct(
        public readonly string $id,
        public readonly string $email,
    ) {}
}
```

## Formatting

- **PHP-CS-Fixer** または **Laravel Pint** でフォーマット
- **PHPStan** または **Psalm** で静的解析
- Composer スクリプトをチェックインし、ローカルと CI で同じコマンドが動くようにする

## Imports

- 参照されるすべてのクラス、インターフェース、トレイトに `use` 文を追加
- プロジェクトが明示的に完全修飾名を優先しない限り、グローバル名前空間に依存しない

## Error Handling

- 例外的状態には例外をスロー — 新しいコードで `false`/`null` を隠れたエラーチャネルとして返さない
- フレームワーク / リクエスト入力をドメインロジックに到達する前に検証済み DTO に変換

## Testing

- **PHPUnit** + **Mockery** または PHPUnit 標準モック
- 80% 以上のカバレッジ
- `phpunit --coverage-html coverage/`
