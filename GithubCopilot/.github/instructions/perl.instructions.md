---
applyTo: "**/*.{pl,pm,t,psgi,cgi}"
---

# Perl ルール

> ECC `rules/perl/` から派生。

## Standards

- 常に `use v5.36`（`strict`、`warnings`、`say`、サブルーチンシグネチャを有効化）
- サブルーチンシグネチャを使用 — `@_` を手動でアンパックしない
- 明示的な改行付き `print` より `say` を優先

## Immutability

- すべての属性に **Moo** + `is => 'ro'` + `Types::Standard` を使用
- bless されたハッシュリファレンスを直接使用しない — 常に Moo/Moose アクセサを使用
- 計算された読み取り専用値には Moo `has` 属性 + `builder` または `default` が許容される

## Formatting

**perltidy** を以下の設定で:

```
-i=4    # 4 スペースインデント
-l=100  # 100 文字行幅
-ce     # cuddled else
-bar    # 開き中括弧は常に右
```

## Linting

severity 3 で **perlcritic** を使用、テーマ: `core`, `pbp`, `security`:

```bash
perlcritic --severity 3 --theme 'core || pbp || security' lib/
```

## Testing

- **Test::More** + **Test::Deep** + **Test2::V0**（モダン）
- 80% 以上のカバレッジ
- `prove -lr t/` または `Devel::Cover` でカバレッジ
