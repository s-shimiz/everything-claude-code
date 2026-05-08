---
applyTo: "**/*.{py,pyi}"
---

# Python ルール

> ECC `rules/python/` から派生。`.github/copilot-instructions.md` の共通ルールを継承して Python 固有の指針を追加。

## Standards

- **PEP 8** 規約に従う
- すべての関数シグネチャに **型アノテーション** を使用
- `black` でフォーマット、`isort` でインポート整列、`ruff` でリント

## Immutability

イミュータブルなデータ構造を優先:

```python
from dataclasses import dataclass

@dataclass(frozen=True)
class User:
    name: str
    email: str

from typing import NamedTuple

class Point(NamedTuple):
    x: float
    y: float
```

## Security

```python
import os
from dotenv import load_dotenv

load_dotenv()

# NEVER: ハードコードされたシークレット
# api_key = "sk-proj-xxxxx"

# ALWAYS: 環境変数（必須キーは KeyError で早期失敗）
api_key = os.environ["OPENAI_API_KEY"]
```

### CRITICAL — Security

- **SQL インジェクション**: クエリ内の f-strings → パラメータ化クエリを使用
- **コマンドインジェクション**: 検証されない入力をシェルコマンドに → `subprocess` のリスト引数を使用
- **パストラバーサル**: ユーザー制御パス → `normpath` で検証、`..` を拒否
- **eval/exec の悪用**, **安全でないデシリアライズ**, **ハードコードされたシークレット**
- **弱い暗号** (MD5/SHA1 をセキュリティ用途に), **YAML unsafe_load**

### Static Security Analysis

```bash
bandit -r src/
```

## Error Handling

### CRITICAL — Error Handling

- **bare except**: `except: pass` → 特定の例外を catch
- **swallowed exceptions**: 静かな失敗 → ログを残して処理
- **Missing context managers**: 手動でのファイル/リソース管理 → `with` を使用

## Patterns

### Protocol (Duck Typing)

```python
from typing import Protocol

class Repository(Protocol):
    def find_by_id(self, id: str) -> dict | None: ...
    def save(self, entity: dict) -> dict: ...
```

### Dataclasses as DTOs

```python
from dataclasses import dataclass

@dataclass
class CreateUserRequest:
    name: str
    email: str
    age: int | None = None
```

### Context Managers & Generators

- リソース管理にはコンテキストマネージャ（`with` 文）を使用
- 遅延評価とメモリ効率的なイテレーションにはジェネレータを使用

## Testing

- フレームワーク: **pytest**
- カバレッジ: `pytest --cov=src --cov-report=term-missing`
- 80% 以上のカバレッジを目標
- AAA パターン（Arrange-Act-Assert）

```python
import pytest

@pytest.mark.unit
def test_calculate_total():
    # Arrange
    items = [10, 20, 30]
    # Act
    total = sum(items)
    # Assert
    assert total == 60

@pytest.mark.integration
def test_database_connection():
    ...
```
