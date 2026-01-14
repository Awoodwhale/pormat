# Pormat

一个在终端中格式化和转换数据（JSON/YAML/TOML/Python）的命令行工具。

## 特性

- **自动检测**：自动检测输入格式（JSON、YAML、TOML 或 Python 字面量）
- **格式转换**：在 JSON、YAML、TOML 和 Python 格式之间相互转换
- **紧凑模式**：使用 `-C` 参数输出紧凑的单行格式
- **可配置**：支持配置文件和命令行选项
- **管道友好**：与 stdin/stdout 无缝集成，适用于 Unix 管道

## 安装

```bash
pip install pormat
```

或使用 uv：

```bash
uv pip install pormat
```

## 使用方法

### 基本用法

从 stdin 格式化输入：

```bash
echo '{"name": "张三", "age": 30}' | pormat
```

将输入作为参数：

```bash
pormat '{"name": "张三", "age": 30}'
```

转换为不同格式：

```bash
echo '{"name": "张三", "age": 30}' | pormat -f yaml
```

### 紧凑模式

输出紧凑的单行格式：

```bash
echo '{"name": "张三", "age": 30}' | pormat --compact
# 输出: {"name":"张三","age":30}

echo '{"name": "张三", "age": 30}' | pormat -C -f yaml
# 输出: {name: 张三, age: 30}
```

### 自定义缩进

```bash
echo '{"name": "张三", "age": 30}' | pormat -i 2
```

### 从文件读取

```bash
cat data.json | pormat -f yaml
pormat -f python < data.json
```

### 格式转换示例

JSON 转 YAML：

```bash
echo '{"users": [{"name": "小明"}, {"name": "小红"}]}' | pormat -f yaml
```

YAML 转 JSON：

```bash
echo '- name: 小明
- name: 小红' | pormat
```

Python 字典转 JSON：

```bash
echo "{'name': '张三', 'age': 30}" | pormat -f json
```

JSON 转 TOML：

```bash
echo '{"name": "pormat", "version": "1.0"}' | pormat -f toml
# 输出:
# name = "pormat"
# version = "1.0"
```

TOML 转 YAML：

```bash
cat Cargo.toml | pormat -f yaml
```

TOML 转 JSON：

```bash
echo '[package]
name = "myapp"
version = "0.1.0"' | pormat -f json
# 输出:
# {
#     "package": {
#         "name": "myapp",
#         "version": "0.1.0"
#     }
# }
```

## 配置

Pormat 支持多种格式的配置文件。在项目目录或主目录中创建配置文件即可。

### 配置文件位置（按搜索顺序）

1. 自定义路径（使用 `-c` 选项）
2. `./pormat.yml`, `./pormat.yaml`
3. `./pormat.toml`
4. `./pormat.json`
5. `.pormat.yml`, `.pormat.yaml`
6. `.pormat.toml`, `.pormat.json`
7. `.env`（使用 `PORMAT_` 前缀）
8. `~/.config/pormat/config.yml`
9. `~/.pormat.yml`

### YAML 配置

```yaml
# pormat.yml
default_format: yaml
default_indent: 2
```

### TOML 配置

```toml
# pormat.toml
default_format = "yaml"
default_indent = 2
```

### JSON 配置

```json
{
  "default_format": "yaml",
  "default_indent": 2
}
```

### 环境变量

```bash
# .env
PORMAT_FORMAT=yaml
PORMAT_INDENT=2
```

### 使用自定义配置

```bash
pormat -c /path/to/config.yml '{"key": "value"}'
```

## 选项

| 选项 | 简写 | 描述 |
|------|------|------|
| `--format` | `-f` | 输出格式：json、yaml、toml、python |
| `--indent` | `-i` | 缩进空格数（默认：4） |
| `--compact` | `-C` | 输出紧凑的单行格式 |
| `--config` | `-c` | 自定义配置文件路径 |
| `--help` | | 显示帮助信息 |

## 实际应用示例

### API 响应格式化

```bash
# 美化 JSON API 响应
curl -s https://api.github.com/users/github | pormat

# 将 API 响应转换为 YAML
curl -s https://api.github.com/users/github | pormat -f yaml -i 2

# 将 API 响应转换为 TOML
curl -s https://api.github.com/repos/python/cpython | pormat -f toml > repo.toml
```

### 配置文件转换

```bash
# 将 pyproject.toml 转换为 YAML
cat pyproject.toml | pormat -f yaml

# 将 package.json 转换为 TOML
cat package.json | pormat -f toml

# 将 Docker Compose YAML 转换为 JSON
cat docker-compose.yml | pormat -f json

# 将 TOML 配置转换为 Python 字典
cat config.toml | pormat -f python
```

### 数据处理

```bash
# 生成紧凑 JSON 用于存储
echo '{"large": "data", "here": true}' | pormat -C > compact.json

# 与 jq 管道组合
cat data.yaml | pormat -f json -C | jq '.key'

# 从 TOML 提取特定字段
cat Cargo.toml | pormat -f json | jq '.package.name'
```

### 多格式工作流

```bash
# Python 配置转 TOML
echo "{'database': {'host': 'localhost', 'port': 5432}}" | pormat -f toml

# YAML 转 Python 字面量
cat config.yml | pormat -f python

# TOML 转 Python 字面量
cat pyproject.toml | pormat -f python
```

### 文件比较

```bash
# 通过转换为相同格式来比较 JSON 和 YAML 文件
diff <(cat file1.json | pormat -f yaml) <(cat file2.yaml | pormat -f yaml)
```

### 项目配置迁移

```bash
# 将项目配置从 JSON 迁移到 TOML
cat package.json | pormat -f toml > pyproject.toml

# 将 Python 配置转换为 YAML
echo "{'DATABASE': {'host': 'localhost'}, 'DEBUG': True}" | pormat -f yaml > config.yml
```

## 架构设计

Pormat 采用模块化、插件式的架构设计，易于扩展和维护。

### 核心组件

```
pormat/
├── cli.py              # 命令行接口 (Typer)
├── detector.py         # 格式自动检测
├── parsers/            # 输入格式解析器
│   ├── json_parser.py
│   ├── yaml_parser.py
│   ├── toml_parser.py
│   └── python_parser.py
├── formatters/         # 输出格式格式化器
│   ├── json_formatter.py
│   ├── yaml_formatter.py
│   ├── toml_formatter.py
│   └── python_formatter.py
├── config/             # 配置管理
│   ├── defaults.py
│   └── loader.py
└── utils/              # 工具函数
    └── io.py
```

### 数据流

```
输入 (stdin/参数)
    ↓
加载配置
    ↓
检测格式 (detector.py)
    ↓
解析输入 (parsers/*)
    ↓
Python 对象
    ↓
格式化输出 (formatters/*)
    ↓
输出 (stdout)
```

### 核心设计原则

1. **关注点分离**：解析、格式化和检测是独立的模块
2. **插件架构**：添加新格式只需两个文件（解析器 + 格式化器）
3. **类型安全**：使用 `Literal` 类型进行编译时格式验证
4. **错误处理**：优雅的降级和清晰的错误提示

## 二次开发

### 添加新格式支持

要添加对新格式（例如 XML）的支持，请按照以下步骤操作：

#### 1. 创建解析器

创建 `src/pormat/parsers/xml_parser.py`：

```python
"""XML 解析器。"""

from typing import Any

class XmlParser:
    """XML 格式解析器。"""

    @staticmethod
    def parse(content: str) -> Any:
        """解析 XML 内容。

        Args:
            content: 要解析的 XML 字符串。

        Returns:
            解析后的 Python 对象（字典）。

        Raises:
            ValueError: 如果内容不是有效的 XML。
        """
        # 在此导入你的 XML 库
        import xmltodict

        try:
            return xmltodict.parse(content)
        except Exception as e:
            raise ValueError(f"无效的 XML: {e}")
```

#### 2. 创建格式化器

创建 `src/pormat/formatters/xml_formatter.py`：

```python
"""XML 格式化器。"""

from typing import Any

class XmlFormatter:
    """XML 输出格式化器。"""

    @staticmethod
    def format(data: Any, indent: int = 4, compact: bool = False) -> str:
        """将数据格式化为 XML。

        Args:
            data: 要格式化的数据（必须是字典）。
            indent: 缩进空格数。
            compact: 如果为 True，输出紧凑格式。

        Returns:
            格式化的 XML 字符串。
        """
        import xmltodict

        if compact:
            return xmltodict.unparse(data, pretty=False)
        return xmltodict.unparse(data, pretty=True, indent=" " * indent)
```

#### 3. 更新导出

更新 `src/pormat/parsers/__init__.py`：

```python
from pormat.parsers.xml_parser import XmlParser

__all__ = ["JsonParser", "YamlParser", "TomlParser", "PythonParser", "XmlParser"]
```

更新 `src/pormat/formatters/__init__.py`：

```python
from pormat.formatters.xml_formatter import XmlFormatter

__all__ = ["JsonFormatter", "YamlFormatter", "TomlFormatter", "PythonFormatter", "XmlFormatter"]
```

#### 4. 在 CLI 中注册

更新 `src/pormat/cli.py`：

```python
from pormat.parsers.xml_parser import XmlParser
from pormat.formatters.xml_formatter import XmlFormatter

FormatType = Literal["json", "yaml", "toml", "python", "xml"]

FORMATTERS = {
    "json": JsonFormatter,
    "yaml": YamlFormatter,
    "toml": TomlFormatter,
    "python": PythonFormatter,
    "xml": XmlFormatter,  # 添加这行
}

PARSERS = {
    "json": JsonParser,
    "yaml": YamlParser,
    "toml": TomlParser,
    "python": PythonParser,
    "xml": XmlParser,  # 添加这行
}
```

#### 5. 更新类型定义

更新 `src/pormat/config/defaults.py`：

```python
DEFAULT_FORMAT: Literal["json", "yaml", "toml", "python", "xml"] = "json"
```

更新 `src/pormat/config/loader.py`：

```python
FormatType = Literal["json", "yaml", "toml", "python", "xml"]
```

更新 `src/pormat/detector.py`：

```python
FormatType = Literal["json", "yaml", "toml", "python", "xml"]

def detect_format(content: str) -> FormatType:
    # ... 现有的检测逻辑 ...

    # 添加 XML 检测
    if _try_parse_xml(content):
        return "xml"

    # ... 函数其余部分 ...

def _try_parse_xml(content: str) -> bool:
    """尝试将内容解析为 XML。"""
    import xmltodict
    try:
        xmltodict.parse(content)
        return True
    except Exception:
        return False
```

#### 6. 添加依赖

更新 `pyproject.toml`：

```toml
dependencies = [
    "typer>=0.12.0",
    "pyyaml>=6.0",
    "tomli>=2.0",
    "tomli-w>=1.0",
    "python-dotenv>=1.0",
    "xmltodict>=0.13.0",  # 添加你的库
]
```

#### 7. 测试

```bash
uv sync
echo '<root><name>test</name></root>' | uv run pormat -f json
```

### 运行测试

```bash
./test.sh
```

### 开发环境设置

```bash
# 克隆仓库
git clone <仓库地址>
cd pormat

# 使用 uv 安装（推荐）
uv sync

# 或使用 pip
pip install -e .

# 运行测试
./test.sh

# 运行工具
uv run pormat '{"key": "value"}'
```

### 贡献指南

欢迎提交 Pull Request！在贡献代码前，请：

1. 确保所有测试通过：`./test.sh`
2. 遵循现有的代码风格
3. 为新功能添加相应的测试
4. 更新相关文档

## 许可证

MIT
