---
applyTo: "**/*.dart"
---

# Dart / Flutter ルール

> ECC `rules/dart/` から派生。

## Formatting

- すべての `.dart` ファイルに **dart format** — CI で強制（`dart format --set-exit-if-changed .`）
- 行幅: 80 文字（dart format デフォルト）
- 複数行引数 / パラメータリストの末尾カンマ

## Immutability

- ローカル変数には `final`、コンパイル時定数には `const`
- すべてのフィールドが `final` の場合は `const` コンストラクタ
- パブリック API から不変コレクション（`List.unmodifiable`, `Map.unmodifiable`）を返す
- 不変状態クラスでは状態変更に `copyWith()`

```dart
// BAD
var count = 0;
List<String> items = ['a', 'b'];

// GOOD
final count = 0;
const items = ['a', 'b'];
```

## Naming

- `camelCase`: 変数、パラメータ、名前付きコンストラクタ
- `PascalCase`: クラス、enum、typedef、extension
- `snake_case`: ファイル名、ライブラリ名
- `SCREAMING_SNAKE_CASE`: トップレベル `const` 定数
- プライベートメンバには `_` プレフィックス
- Extension 名は拡張する型を示す: `StringExtensions`

## Null Safety

- `!`（bang 演算子）を避ける — `?.`, `??`, `if (x != null)` または Dart 3 パターンマッチを優先
- `late` を避ける — nullable または constructor 初期化を優先
- 必須コンストラクタパラメータには `required`

## Flutter

- `StatelessWidget` を `StatefulWidget` より優先
- 状態管理: Riverpod / Bloc / Provider（プロジェクトの選択に従う）
- リアクティブビルドのため、ビルドメソッドで重い計算を避ける
- パフォーマンス向上のため可能な限り `const` ウィジェット

## Testing

- **flutter_test** + **mocktail** または **mockito**
- 80% 以上のカバレッジ
- ウィジェットテスト + ゴールデンテスト
