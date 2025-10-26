#!/bin/bash

# Script to write OS to USB drive
# WARNING: This will ERASE ALL DATA on the target drive!

if [ ! -f bin/os.bin ]; then
    echo "Error: bin/os.bin not found!"
    echo "Run './build.sh' first to build the OS"
    exit 1
fi

echo "==================================="
echo "  WARNING: THIS WILL ERASE DATA!"
echo "==================================="
echo ""
echo "Available drives:"
lsblk -d -o NAME,SIZE,TYPE,MODEL | grep disk
echo ""
echo "Enter the device name (e.g., sdb, NOT sdb1):"
echo "NOTE: Do NOT include /dev/ prefix"
read -p "Device: " device

# Validate input
if [ -z "$device" ]; then
    echo "Error: No device specified"
    exit 1
fi

# Add /dev/ prefix
device="/dev/$device"

# Check if device exists
if [ ! -b "$device" ]; then
    echo "Error: $device is not a valid block device"
    exit 1
fi

# Check if it's sda (usually main hard drive)
if [[ "$device" == "/dev/sda" ]]; then
    echo "Error: Refusing to write to /dev/sda (likely your main hard drive)"
    echo "If you really want to do this, edit the script"
    exit 1
fi

echo ""
echo "You are about to write to: $device"
echo "This will PERMANENTLY ERASE all data on this drive!"
echo ""
read -p "Type 'YES' to confirm: " confirm

if [ "$confirm" != "YES" ]; then
    echo "Aborted."
    exit 1
fi

echo ""
echo "Writing OS to $device..."
echo "This may take a few seconds..."

# Unmount if mounted
sudo umount ${device}* 2>/dev/null

# Write the OS image
sudo dd if=bin/os.bin of=$device bs=512 status=progress

# Sync to ensure write is complete
sudo sync

echo ""
echo "Done! OS written to $device"
echo ""
echo "To boot from USB:"
echo "1. Restart your computer"
echo "2. Enter BIOS/UEFI (usually F2, F12, Del, or Esc)"
echo "3. Change boot order to boot from USB first"
echo "4. Or use boot menu (usually F12) to select USB drive"
echo ""
echo "NOTE: This OS requires BIOS/Legacy boot mode, NOT UEFI!"
