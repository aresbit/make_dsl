# Graydon DSL - Supported Makefile Syntax

This document describes the subset of Makefile syntax supported by the Graydon DSL compiler.

## Overview

The Graydon DSL compiler implements a simplified subset of GNU Make functionality, focusing on basic variable assignments and rule definitions.

## Supported Syntax Elements

### 1. Variable Assignments

#### Basic Variable Assignment
```makefile
VARIABLE = value
NAME = myprogram
CC = gcc
```

#### Multi-word Values
```makefile
CFLAGS = -Wall -O2 -g
SOURCES = main.c utils.c parser.c
```

### 2. Rules

#### Basic Rules
```makefile
target: dependency1 dependency2
	command1
	command2
```

#### Examples
```makefile
program: main.o utils.o
	gcc -o program main.o utils.o

main.o: main.c
	gcc -c main.c

utils.o: utils.c utils.h
	gcc -c utils.c
```

### 3. Variables in Rules

#### Simple Variable References
```makefile
CC = gcc
program: main.c
	$(CC) -o program main.c
```

## Unsupported Syntax

The following Makefile features are **not supported**:

### 1. Advanced Variable Types
- `:=` (immediate assignment)
- `?=` (conditional assignment)
- `+=` (append assignment)
- `define` ... `endef` (multi-line variables)

### 2. Pattern Rules
```makefile
%.o: %.c
	$(CC) -c $< -o $@
```

### 3. Automatic Variables
- `$@` (target)
- `$<` (first dependency)
- `$^` (all dependencies)
- `$*` (stem in pattern rules)

### 4. Functions
```makefile
SOURCES = $(wildcard *.c)
OBJECTS = $(SOURCES:.c=.o)
```

### 5. Conditionals
```makefile
ifeq ($(CC),gcc)
    CFLAGS += -DGCC
endif
```

### 6. Include Statements
```makefile
include config.mk
```

### 7. Special Targets
```makefile
.PHONY: clean all
.DEFAULT: all
```

## Grammar Summary

### Lexical Elements
- **WORDS**: Regular text tokens
- **VAR**: Variables starting with `$` (e.g., `$CC`, `$NAME`)
- **SPEC**: Special characters and literals
- **BACKSLASH**: Line continuation `\`

### Syntax Rules

```ebnf
file ::= statement*
statement ::= assignment | rule

assignment ::= WORD EQUAL words
rule ::= target COLON dependencies actions

target ::= WORD | VAR | SPEC
dependencies ::= (WORD | VAR | SPEC)*
actions ::= (WORD | VAR | SPEC | BACKSLASH)*

words ::= (WORD | VAR | SPEC)*
```

## Examples of Valid Files

### Example 1: Simple Build
```makefile
CC = gcc
program: main.c
	gcc -o program main.c
```

### Example 2: Multiple Objects
```makefile
CC = gcc
CFLAGS = -Wall -O2

program: main.o utils.o
	gcc -o program main.o utils.o

main.o: main.c
	gcc -c main.c

utils.o: utils.c
	gcc -c utils.c
```

### Example 3: Variables in Commands
```makefile
CC = gcc
CFLAGS = -Wall -O2
TARGET = myapp

$(TARGET): main.c
	$(CC) $(CFLAGS) -o $(TARGET) main.c
```

## Limitations

1. **No Pattern Matching**: Cannot use `%` patterns for generic rules
2. **No Automatic Variables**: Must explicitly name all files
3. **No String Manipulation**: No substitution or filtering functions
4. **Simple Dependencies**: Only direct file dependencies supported
5. **Basic Execution**: Commands are executed sequentially without optimization

## Notes

- All variable references must be simple names (e.g., `$CC`, not `${CC}` or `$(CC)`)
- Commands are executed as-is without shell interpretation
- File paths should be simple relative paths
- The compiler generates standalone OCaml executables that implement the build logic