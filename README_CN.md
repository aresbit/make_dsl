# Graydon DSL - Makefile 编译器

一个快速的 DSL 编译器，用于 Make(1) 构建系统语言的子集，灵感来自 Graydon 的 "One-Day Compilers" 系列演讲。

## 功能

- **Makefile 语法支持**：变量、规则、依赖关系和操作
- **静态编译**：将 Makefile 编译为原生可执行文件
- **变量扩展**：完整的变量引用和扩展
- **依赖分析**：自动构建依赖图
- **增量构建**：仅在依赖项更改时重新构建目标

## 架构

编译器采用 2 阶段架构：

1. **Makefile → OCaml**：解析 Makefile 并生成 OCaml 代码
2. **OCaml → C**：通过 ocamlc 将 OCaml 编译为 C
3. **C → 原生**：通过 gcc 生成最终可执行文件

## 快速开始

### 前提条件

- OCaml ≥ 4.08
- Dune 构建系统
- GCC 编译器

### 安装

```bash
# 克隆仓库
git clone <仓库地址>
cd Graydon_dsl

# 构建项目
dune build

# 安装编译器
dune install
```

### 使用

```bash
# 编译 Makefile
graydon_dsl examples/simple.mk

# 指定输出可执行文件名
graydon_dsl examples/simple.mk mybuild

# 运行生成的构建系统
./mybuild
```

## 支持的语法

### 变量
```makefile
CC = gcc
CFLAGS = -Wall -O2
OBJECTS = main.o utils.o
```

### 构建规则
```makefile
program: $(OBJECTS)
	$(CC) -o $@ $^

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@
```

### 特殊变量
- `$@` - 目标名称
- `$^` - 所有依赖项
- `$<` - 第一个依赖项

## 示例

### 简单构建
```makefile
# examples/simple.mk
CC = gcc
OBJS = main.o utils.o

program: $(OBJS)
	$(CC) -o program $(OBJS)

main.o: main.c
	$(CC) -c main.c

utils.o: utils.c
	$(CC) -c utils.c
```

### 带变量的复杂构建
```makefile
# examples/variables.mk
CXX = g++
CXXFLAGS = -std=c++17 -Wall

SOURCES = main.cpp utils.cpp
OBJECTS = $(SOURCES:.cpp=.o)

myapp: $(OBJECTS)
	$(CXX) -o $@ $^

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@
```

## 开发

### 项目结构
```
Graydon_dsl/
├── src/
│   ├── lexer.mll          # 词法分析器
│   ├── parser.mly         # 解析器语法
│   ├── ast.ml            # 抽象语法树
│   ├── semantic.ml       # 语义分析
│   ├── codegen.ml        # 代码生成
│   └── main.ml           # 主驱动程序
├── examples/             # 示例 Makefile
├── tests/               # 测试套件
└── README.md
```

### 从源代码构建

```bash
# 构建项目
dune build

# 运行测试
dune test

# 清理构建产物
dune clean
```

### 测试

```bash
# 测试简单示例
cd examples
../_build/default/src/main.exe simple.mk
./simple

# 测试带变量的示例
../_build/default/src/main.exe variables.mk
./variables
```

## 实现细节

### 词法分析器 (`lexer.mll`)
- 对 Makefile 语法进行词法分析
- 处理变量、特殊字符和注释
- 提供错误时的源代码位置信息

### 解析器 (`parser.mly`)
- 变量赋值和构建规则的语法
- LL(1) 递归下降解析器
- 构建抽象语法树

### 语义分析 (`semantic.ml`)
- 变量绑定和作用域解析
- 依赖图构建
- 构建顺序的拓扑排序

### 代码生成 (`codegen.ml`)
- 将 Makefile AST 转换为 OCaml 函数
- 生成构建系统的 C 代码
- 实现文件操作的运行时支持

## 限制

- 仅支持基本的 Makefile 语法
- 不支持高级功能，如模式规则、条件语句或包含文件
- 简化的变量扩展
- 不支持并行构建

## 许可证

MIT 许可证 - 详见 LICENSE 文件。

## 贡献

欢迎贡献！请阅读 CONTRIBUTING.md 了解指南。