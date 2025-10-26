#!/bin/bash

echo "Building UEFI x86_64 OS (Arch Linux)..."
echo "======================================="

# Check for required packages
missing_packages=()

if [ ! -f /usr/lib/crt0-efi-x86_64.o ]; then
    missing_packages+=("gnu-efi")
fi

if ! command -v mtools &> /dev/null; then
    missing_packages+=("mtools")
fi

if ! command -v qemu-system-x86_64 &> /dev/null; then
    missing_packages+=("qemu-full")
fi

# Check for OVMF in multiple possible locations
#if [ ! -f /usr/share/edk2-ovmf/x64/OVMF_CODE.fd ] && \
#   [ ! -f /usr/share/ovmf/x64/OVMF_CODE.fd ] && \
#   [ ! -f /usr/share/OVMF/OVMF_CODE.fd ]; then
#    missing_packages+=("edk2-ovmf")
#fi

if [ ${#missing_packages[@]} -ne 0 ]; then
    echo "Error: Missing required packages:"
    printf '  - %s\n' "${missing_packages[@]}"
    echo ""
    echo "Install with:"
    echo "  sudo pacman -S ${missing_packages[*]}"
    exit 1
fi

# Clean previous build
make -f Makefile.uefi clean

# Build UEFI bootloader and kernel
make -f Makefile.uefi uefi

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ Build successful!"
    echo ""
    echo "Files created:"
    echo "  - UEFI bootloader: efi/BOOTX64.EFI"
    echo "  - Kernel: bin/kernel.bin"
    echo "  - USB image: usb.img"
    echo ""
    echo "Next steps:"
    echo "  Test:  ./run_uefi.sh"
    echo "  USB:   sudo dd if=usb.img of=/dev/sdX bs=1M status=progress"
else
    echo ""
    echo "✗ Build failed!"
    exit 1
fi
