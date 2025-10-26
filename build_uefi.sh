#!/usr/bin/env bash
# Build script: creates a FAT ESP image (esp.img), builds a GRUB EFI (BOOTX64.EFI)
# with useful modules (fat, elf, multiboot, search, normal, echo, etc.), copies grub.cfg
# (if present) and kernel.bin (if present) into the image.
set -euo pipefail

OUTDIR=out
ESP_IMG=esp.img
ESP_SIZE_MB=64
MOUNTDIR=/tmp/espmnt_myos
BOOT_PATH=EFI/BOOT
BOOT_EFI="${OUTDIR}/BOOTX64.EFI"
GRUB_CFG_SRC="grub.cfg"    # will be copied into /EFI/BOOT/grub.cfg if exists
KERNEL_SRC="bin/kernel.bin"    # will be copied to /kernel.bin if exists

mkdir -p "${OUTDIR}"

# Helper to find a grubx64.efi candidate if grub-mkimage is not available
find_system_grub_efi() {
  local candidates=(
    /usr/lib/grub/x86_64-efi/grubx64.efi
    /usr/lib/grub/x86_64-efi/core.efi
    /boot/efi/EFI/grub/grubx64.efi
    /boot/efi/EFI/BOOT/BOOTX64.EFI
    /usr/share/grub/x86_64-efi/grubx64.efi
  )
  for p in "${candidates[@]}"; do
    if [ -f "$p" ]; then
      echo "$p"
      return 0
    fi
  done
  return 1
}

echo "=== Building GRUB EFI (BOOTX64.EFI) ==="

if command -v grub-mkimage >/dev/null 2>&1; then
  echo "Found grub-mkimage -> building BOOTX64.EFI with modules..."
  grub-mkimage -O x86_64-efi -o "${BOOT_EFI}" -p /${BOOT_PATH} \
    fat part_gpt part_msdos normal search configfile linux multiboot elf chain boot \
    echo cat read loopback
  echo "Created: ${BOOT_EFI}"
else
  echo "grub-mkimage not found. Searching for an existing grubx64.efi to copy..."
  SYS_GRUB=$(find_system_grub_efi || true)
  if [ -n "${SYS_GRUB}" ]; then
    echo "Found system grub EFI at: ${SYS_GRUB}"
    cp "${SYS_GRUB}" "${BOOT_EFI}"
    echo "Copied system grub EFI to: ${BOOT_EFI}"
  else
    echo "ERROR: grub-mkimage not available and no grubx64.efi found on the system."
    echo "Install grub (grub-mkimage) or provide a grubx64.efi. On Arch: sudo pacman -S grub"
    exit 1
  fi
fi

echo "=== Creating FAT ESP image (${ESP_IMG}) ==="
rm -f "${ESP_IMG}"
dd if=/dev/zero of="${ESP_IMG}" bs=1M count="${ESP_SIZE_MB}" status=none
mkfs.vfat -F 32 "${ESP_IMG}"

echo "=== Mounting and copying files into ESP image ==="
sudo mkdir -p "${MOUNTDIR}"
sudo mount -o loop "${ESP_IMG}" "${MOUNTDIR}"

sudo mkdir -p "${MOUNTDIR}/${BOOT_PATH}"
sudo cp "${BOOT_EFI}" "${MOUNTDIR}/${BOOT_PATH}/BOOTX64.EFI"
echo "Copied BOOTX64.EFI -> /${BOOT_PATH}/BOOTX64.EFI inside image"

if [ -f "${GRUB_CFG_SRC}" ]; then
  sudo cp "${GRUB_CFG_SRC}" "${MOUNTDIR}/${BOOT_PATH}/grub.cfg"
  echo "Copied ${GRUB_CFG_SRC} -> /${BOOT_PATH}/grub.cfg"
else
  echo "No grub.cfg found in repo root; creating a minimal grub.cfg at /${BOOT_PATH}/grub.cfg"
  sudo tee "${MOUNTDIR}/${BOOT_PATH}/grub.cfg" >/dev/null <<'EOF'
set timeout=5
set default=0

insmod part_gpt
insmod fat
insmod normal
insmod search
insmod elf
insmod multiboot

menuentry "MyOS (ELF)" {
  search --file --no-floppy --set=root /kernel.bin
  echo "Loading /kernel.bin via elf..."
  elf /kernel.bin
}

menuentry "MyOS (Multiboot)" {
  search --file --no-floppy --set=root /kernel.bin
  echo "Loading /kernel.bin via multiboot..."
  multiboot /kernel.bin
  module /kernel.bin
  boot
}
EOF
  echo "Wrote minimal grub.cfg"
fi

if [ -f "${KERNEL_SRC}" ]; then
  sudo cp "${KERNEL_SRC}" "${MOUNTDIR}/kernel.bin"
  echo "Copied ${KERNEL_SRC} -> /kernel.bin inside image"
else
  echo "Warning: ${KERNEL_SRC} not found in repo root. Put your kernel ELF at ${KERNEL_SRC} or edit the script."
fi

sync
sudo umount "${MOUNTDIR}"
sudo rmdir "${MOUNTDIR}" || true

echo "=== Done ==="
echo "ESP image: ${ESP_IMG}"
echo "BOOTX64.EFI: ${BOOT_EFI}"
echo "If you want to test in QEMU run ./run.sh"
