#!/bin/bash

echo "Building x86_64 OS..."
echo "===================="

# Clean previous build
make clean

# Build the OS
make

if [ $? -eq 0 ]; then
    echo ""
    echo "Build successful!"
    echo "OS binary: bin/os.bin"
    echo ""
    echo "Run './run.sh' to start the OS in QEMU"
else
    echo ""
    echo "Build failed!"
    exit 1
fi
