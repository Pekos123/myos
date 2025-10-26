// Minimal UEFI bootloader
#define EFIAPI __attribute__((ms_abi))

typedef unsigned long long UINTN;
typedef unsigned short CHAR16;
typedef void* EFI_HANDLE;

typedef struct {
    UINTN Signature;
    UINTN Revision;
    UINTN HeaderSize;
    UINTN CRC32;
    UINTN Reserved;
} EFI_TABLE_HEADER;

typedef struct {
    EFI_TABLE_HEADER Hdr;
    CHAR16* FirmwareVendor;
    UINTN FirmwareRevision;
} EFI_SYSTEM_TABLE;

// Simple UEFI main function
EFIAPI UINTN efi_main(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable) {
    // Simple: just jump to kernel at 1MB
    void (*kernel)() = (void(*)())0x100000;
    kernel();
    return 0;
}
