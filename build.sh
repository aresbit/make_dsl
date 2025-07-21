#!/bin/bash
set -e

echo "Building Make DSL compiler..."

# Build the compiler
dune build

echo "✓ Make DSL compiler built successfully"

# Test with simple example
echo "Testing with working makefile..."

# Create test directory if it doesn't exist
mkdir -p examples

cd examples

echo "Creating test Makefile..."

# Create a simple test Makefile
cat > Makefile << 'EOF'
CC = gcc
CFLAGS = -Wall -O2
TARGET = hello

$(TARGET): main.c
	$(CC) $(CFLAGS) -o $(TARGET) main.c
EOF

echo "Created test Makefile with content:"
echo "---"
cat Makefile
echo "---"

# Create a simple main.c for testing
cat > main.c << 'EOF'
#include <stdio.h>

int main() {
    printf("Hello from Make DSL compiled makefile!\n");
    return 0;
}
EOF

echo "Building test makefile with Make DSL compiler..."

# Use the compiled Make DSL compiler to compile the Makefile
../_build/default/src/main.exe Makefile simple_build

if [ -f "simple_build" ]; then
    echo "✓ Successfully compiled Makefile to executable 'simple_build'"
    echo "Generated files:"
    ls -la simple_build*
    
    echo ""
    echo "Running the generated build system..."
    ./simple_build
    
    if [ -f "hello" ]; then
        echo "✓ Build system successfully created target 'hello'"
        echo "Testing the compiled program:"
        ./hello
        echo "✓ Program runs successfully!"
    else
        echo "✗ Build system ran but didn't create expected target 'hello'"
        exit 1
    fi
    
else
    echo "✗ Failed to compile Makefile to executable"
    echo "Checking for generated OCaml file:"
    if [ -f "simple_build.ml" ]; then
        echo "Found generated OCaml code:"
        echo "---"
        head -20 simple_build.ml
        echo "---"
    fi
    exit 1
fi

echo ""
echo "🎉 Compiler is working! All tests passed!"
echo "✓ Make DSL compiler built successfully"
echo "✓ Makefile compilation successful" 
echo "✓ Generated build system works correctly"
echo "✓ Final program executes properly"

# Cleanup test files
echo ""
echo "Cleaning up test files..."
rm -f hello main.c simple_build simple_build.ml Makefile
cd ..

echo "Test completed successfully!"