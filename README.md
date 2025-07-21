# Make DSL - A Makefile Compiler

A rapid DSL compiler for a subset of the Make(1) build system language, inspired by Graydon's "One-Day Compilers" talk series.

## Features

- **Makefile syntax support**: Variables, rules, dependencies, and actions
- **Static compilation**: Compiles Makefiles to native executables
- **Variable expansion**: Full variable reference and expansion
- **Dependency analysis**: Automatic dependency graph construction
- **Incremental builds**: Only rebuilds targets when dependencies change

## Architecture

The compiler follows a 2-stage architecture:

1. **Makefile → OCaml**: Parse Makefile and generate OCaml code
2. **OCaml → C**: Compile OCaml to C via ocamlc
3. **C → Native**: Generate final executable via gcc

## Quick Start

### Prerequisites

- OCaml ≥ 4.08
- Dune build system
- GCC compiler

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd make_dsl

# Build the project
dune build

# Install the compiler
dune install
```

### Usage
see build.sh or

```bash
# 步骤1：编译make DSL编译器
dune build
# 生成：./_build/default/src/main.exe

# 步骤2：准备一个Makefile
cat > Makefile << 'EOF'
CC = gcc
CFLAGS = -Wall -O2
TARGET = hello

$(TARGET): main.c
	$(CC) $(CFLAGS) -o $(TARGET) main.c

clean:
	rm -f $(TARGET)
EOF

# 步骤3：用make编译器编译Makefile
./_build/default/src/main.exe Makefile my_build_tool
# 这一步做了：
# - 读取Makefile
# - 解析成AST
# - 生成OCaml代码（my_build_tool.ml）
# - 编译OCaml代码成可执行文件（my_build_tool）

# 步骤4：使用生成的构建工具
./my_build_tool
# 这会执行Makefile中定义的构建规则
```

## Supported Syntax

### Variables
```makefile
CC = gcc
CFLAGS = -Wall -O2
OBJECTS = main.o utils.o
```

### Build Rules
```makefile
program: $(OBJECTS)
	$(CC) -o $@ $^

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@
```

### Special Variables--todo
- `$@` - Target name
- `$^` - All dependencies
- `$<<` - First dependency

## Examples

### Simple Build
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

### Complex Build with Variables
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

## Development

### Project Structure
```
make_dsl/
├── src/
│   ├── lexer.mll          # Lexical analyzer
│   ├── parser.mly         # Parser grammar
│   ├── ast.ml            # Abstract syntax tree
│   ├── semantic.ml       # Semantic analysis
│   ├── codegen.ml        # Code generation
│   └── main.ml           # Main driver
├── examples/             # Example Makefiles
├── tests/               # Test suite
└── README.md
```

### Building from Source

```bash
# Build the project
dune build

# Run tests
dune test

# Clean build artifacts
dune clean
```

### Testing

```bash
# Test with simple example
cd examples
../_build/default/src/main.exe simple.mk
./simple

# Test with variables example
../_build/default/src/main.exe variables.mk
./variables
```

## Implementation Details

### Lexer (`lexer.mll`)
- Tokenizes Makefile syntax
- Handles variables, special characters, comments
- Provides source location information for errors

### Parser (`parser.mly`)
- Grammar for variable assignments and build rules
- LL(1) recursive descent parser
- Builds abstract syntax tree

### Semantic Analysis (`semantic.ml`)
- Variable binding and scope resolution
- Dependency graph construction
- Topological sorting for build order

### Code Generation (`codegen.ml`)
- Transforms Makefile AST to OCaml functions
- Generates C code for build system
- Implements runtime support for file operations

## Limitations

- Limited to basic Makefile syntax
- No advanced features like pattern rules, conditionals, or includes
- Simplified variable expansion
- No parallel builds

## License

MIT License - see LICENSE file for details.

## Contributing

Contributions welcome! Please read SUPPORTED_SYNTAX_TODO.md for guidelines.