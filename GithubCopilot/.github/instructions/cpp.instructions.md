---
applyTo: "**/*.{cpp,hpp,cc,hh,cxx,h,c}"
---

# C/C++ ルール

> ECC `rules/cpp/` から派生。

## Modern C++ (C++17/20/23)

- C スタイルではなく **モダン C++ 機能** を優先
- 型がコンテキストから明白なら `auto` を使用
- コンパイル時定数には `constexpr`
- 構造化束縛: `auto [key, value] = map_entry;`

## Resource Management

- **RAII** 必須 — 手動の `new`/`delete` 禁止
- 排他的所有権には `std::unique_ptr`
- 共有所有権が本当に必要な場合のみ `std::shared_ptr`
- 生 `new` より `std::make_unique` / `std::make_shared`

```cpp
// BAD
Widget* w = new Widget();
delete w;

// GOOD
auto w = std::make_unique<Widget>();
```

## Naming Conventions

- 型/クラス: `PascalCase`
- 関数/メソッド: `snake_case` または `camelCase`（プロジェクトの規約に従う）
- 定数: `kPascalCase` または `UPPER_SNAKE_CASE`
- 名前空間: `lowercase`
- メンバ変数: `snake_case_`（末尾アンダースコア）または `m_` プレフィックス

## Formatting

- **clang-format** を使用 — スタイル論争なし
- コミット前に `clang-format -i <file>`

## Error Handling

- 例外を使用、エラーコードは可能なら避ける
- 例外安全保証を文書化（強い、基本、なし）
- リソース管理は RAII で（手動 cleanup なし）

## Const Correctness

- ミューテートしないメソッドは `const`
- 参照パラメータはミューテートしないなら `const`
- 値を返さないなら戻り値型から `const` を外す

## Concurrency

- スレッドセーフのために `std::mutex`, `std::shared_mutex`
- アトミック操作には `std::atomic`
- `std::thread` より `std::async` または高レベルの並行ユーティリティ

## Testing

- **GoogleTest** + **gcov/lcov**（カバレッジ）
- 80% 以上のカバレッジ
