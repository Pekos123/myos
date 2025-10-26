#!/bin/bash

if [ ! -f usb.img ]; then
    echo "Error: usb.img not found!"
    echo "Run './build_uefi.sh' first to build the OS"
    exit 1
fi

# Check for OVMF firmware (Arch location)
OVMF_CODE="/usr/share/edk2/x64/OVMF_CODE.4m.fd"
OVMF_VARS="/usr/share/edk2/x64/OVMF_VARS.4m.fd"

if [ ! -f "$OVMF_CODE" ]; then
    # Try alternative locations
    if [ -f /usr/share/edk2-ovmf/x64/OVMF_CODE.fd ]; then
        OVMF_CODE="/usr/share/edk2-ovmf/x64/OVMF_CODE.fd"
        OVMF_VARS="/usr/share/edk2-ovmf/x64/OVMF_VARS.fd"
    else
        echo "Error: OVMF firmware not found!"
        echo "Install with: sudo pacman -S edk2-ovmf"
        exit 1
    fi
fi

echo "Starting x86_64 OS in QEMU (UEFI mode)..."
echo "========================================="
echo "Press Ctrl+Alt+G to release mouse"
echo "Press Ctrl+C to quit"
echo ""

# Create temporary VARS file (UEFI variables)
cp "$OVMF_VARS" /tmp/OVMF_VARS.fd 2>/dev/null

qemu-system-x86_64 \
    -drive if=pflash,format=raw,readonly=on,file="$OVMF_CODE" \
    -drive if=pflash,format=raw,file=/tmp/OVMF_VARS.fd \
    -drive format=raw,file=usb.img \
    -m 256M \
    -cpu qemu64 \
    -net none

# Clean up
rm -f /tmp/OVMF_VARS.fd
