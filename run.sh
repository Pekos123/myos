#!/usr/bin/env bash
set -euo pipefail

ESP_IMG=esp.img

if [ ! -f "${ESP_IMG}" ]; then
  echo "ESP image ${ESP_IMG} not found. Run ./build.sh first."
  exit 1
fi

# Common Arch OVMF path
OVMF_CODE="/usr/share/edk2/x64/OVMF_CODE.4m.fd"
OVMF_VARS="/usr/share/edk2/x64/OVMF_VARS.4m.fd"

TMP_VARS=""
cleanup() {
  if [ -n "${TMP_VARS:-}" ] && [ -f "${TMP_VARS}" ]; then
    rm -f "${TMP_VARS}"
  fi
}
trap cleanup EXIT

# If vars available, copy to a tmp writable file
if [ -n "${OVMF_VARS}" ]; then
  TMP_VARS="$(mktemp /tmp/OVMF_VARS.XXXXXX.fd)"
  cp "${OVMF_VARS}" "${TMP_VARS}"
  echo "Copied OVMF_VARS to temporary file: ${TMP_VARS}"
fi

# Check combined pflash sizes (QEMU limitation)
CODE_SIZE=$(stat -c%s "${OVMF_CODE}")
VARS_SIZE=0
if [ -n "${TMP_VARS}" ]; then VARS_SIZE=$(stat -c%s "${TMP_VARS}"); fi
TOTAL_SIZE=$((CODE_SIZE + VARS_SIZE))
LIMIT=$((8 * 1024 * 1024))

# Base QEMU args
QEMU_BASE=(qemu-system-x86_64 -m 1024 -drive file="${ESP_IMG}",format=raw,if=ide -serial stdio -display none)

if [ "${TOTAL_SIZE}" -gt "${LIMIT}" ]; then
  echo "Combined OVMF pflash size too large (${TOTAL_SIZE} bytes). Using -bios fallback."
  QEMU_BASE+=(-bios "${OVMF_CODE}")
else
  echo "Using pflash for firmware."
  QEMU_BASE+=(-drive if=pflash,format=raw,readonly=on,file="${OVMF_CODE}")
  if [ -n "${TMP_VARS}" ]; then
    QEMU_BASE+=(-drive if=pflash,format=raw,file="${TMP_VARS}")
  fi
fi

echo "Starting QEMU..."
"${QEMU_BASE[@]}"
