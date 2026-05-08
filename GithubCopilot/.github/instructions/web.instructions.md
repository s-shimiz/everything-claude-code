---
applyTo: "**/*.{html,htm,css,scss,sass,less}"
---

# Web (HTML/CSS) ルール

> ECC `rules/web/` から派生。

## File Organization

ファイルタイプではなく、機能 / サーフェスエリアで整理:

```text
src/
├── components/
│   ├── hero/
│   │   ├── Hero.tsx
│   │   ├── HeroVisual.tsx
│   │   └── hero.css
│   ├── scrolly-section/
│   │   ├── ScrollySection.tsx
│   │   ├── StickyVisual.tsx
│   │   └── scrolly.css
│   └── ui/
│       ├── Button.tsx
│       ├── SurfaceCard.tsx
│       └── AnimatedText.tsx
├── hooks/
│   ├── useReducedMotion.ts
│   └── useScrollProgress.ts
├── lib/
│   ├── animation.ts
│   └── color.ts
└── styles/
    ├── tokens.css
    ├── typography.css
    └── global.css
```

## CSS Custom Properties

デザイントークンを変数として定義。パレット、タイポグラフィ、スペーシングを繰り返しハードコードしない:

```css
:root {
  --color-surface: oklch(98% 0 0);
  --color-text: oklch(18% 0 0);
  --color-accent: oklch(68% 0.21 250);

  --text-base: clamp(1rem, 0.92rem + 0.4vw, 1.125rem);
  --text-hero: clamp(3rem, 1rem + 7vw, 8rem);

  --space-section: clamp(4rem, 3rem + 5vw, 10rem);
}
```

## Modern CSS Features

- **Container queries** — コンポーネントベースのレスポンシブ
- **CSS Grid** + **subgrid** — 複雑なレイアウト
- **`oklch()`** — 知覚的に一貫した色
- **`clamp()`** — 流動的タイポグラフィ・スペーシング
- **`:has()`** — 親セレクタ
- **CSS Cascade Layers** — `@layer` でスタイル優先順位を制御

## Accessibility

- セマンティック HTML を優先（`<button>`, `<nav>`, `<main>` 等）
- インタラクティブ要素に ARIA ラベル
- カラーコントラスト比 4.5:1 以上（テキスト）
- キーボードナビゲーション対応
- `prefers-reduced-motion` を尊重

## Performance

- 重要 CSS をインライン化
- フォントを `font-display: swap` で読み込む
- 画像は `loading="lazy"`、レスポンシブ用に `srcset`
- レイアウトシフトを避けるため、画像 / iframe に幅・高さを指定

## Testing

- **Playwright** で E2E
- ビジュアル回帰テスト
- a11y テスト（`@axe-core/playwright`）
