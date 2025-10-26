#include <efi.h>
#include <efilib.h>

// UEFI Application Entry Point
EFI_STATUS EFIAPI efi_main(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable) {
    EFI_STATUS Status;
    EFI_LOADED_IMAGE *LoadedImage = NULL;
    EFI_FILE_PROTOCOL *Root = NULL;
    EFI_FILE_PROTOCOL *KernelFile = NULL;
    
    // Initialize UEFI library
    InitializeLib(ImageHandle, SystemTable);
    
    // Clear screen and show we're loading
    SystemTable->ConOut->ClearScreen(SystemTable->ConOut);
    SystemTable->ConOut->OutputString(SystemTable->ConOut, L"MyOS Bootloader Starting...\r\n");
    
    // Get the loaded image protocol
    Status = SystemTable->BootServices->HandleProtocol(
        ImageHandle, 
        &gEfiLoadedImageProtocolGuid, 
        (VOID**)&LoadedImage
    );
    
    if (EFI_ERROR(Status)) {
        SystemTable->ConOut->OutputString(SystemTable->ConOut, L"Error: Cannot get loaded image\r\n");
        return Status;
    }
    
    // Get the file system protocol
    EFI_SIMPLE_FILE_SYSTEM_PROTOCOL *FileSystem;
    Status = SystemTable->BootServices->HandleProtocol(
        LoadedImage->DeviceHandle,
        &gEfiSimpleFileSystemProtocolGuid,
        (VOID**)&FileSystem
    );
    
    if (EFI_ERROR(Status)) {
        SystemTable->ConOut->OutputString(SystemTable->ConOut, L"Error: Cannot get file system\r\n");
        return Status;
    }
    
    // Open the root directory
    Status = FileSystem->OpenVolume(FileSystem, &Root);
    if (EFI_ERROR(Status)) {
        SystemTable->ConOut->OutputString(SystemTable->ConOut, L"Error: Cannot open volume\r\n");
        return Status;
    }
    
    // Try to open kernel.bin
    Status = Root->Open(Root, &KernelFile, L"kernel.bin", EFI_FILE_MODE_READ, 0);
    if (EFI_ERROR(Status)) {
        SystemTable->ConOut->OutputString(SystemTable->ConOut, L"Error: Cannot find kernel.bin\r\n");
        Root->Close(Root);
        return Status;
    }
    
    // Get file info to determine size
    EFI_FILE_INFO *FileInfo;
    UINTN InfoSize = sizeof(EFI_FILE_INFO) + 128;
    FileInfo = AllocatePool(InfoSize);
    
    Status = KernelFile->GetInfo(KernelFile, &gEfiFileInfoGuid, &InfoSize, FileInfo);
    if (EFI_ERROR(Status)) {
        SystemTable->ConOut->OutputString(SystemTable->ConOut, L"Error: Cannot get kernel size\r\n");
        FreePool(FileInfo);
        KernelFile->Close(KernelFile);
        Root->Close(Root);
        return Status;
    }
    
    UINTN KernelSize = FileInfo->FileSize;
    SystemTable->ConOut->OutputString(SystemTable->ConOut, L"Kernel size: ");
    SystemTable->ConOut->OutputString(SystemTable->ConOut, L"\r\n");
    
    FreePool(FileInfo);
    
    // Allocate memory for kernel at 1MB
    EFI_PHYSICAL_ADDRESS KernelAddress = 0x100000;
    UINTN Pages = (KernelSize + 0xFFF) >> 12; // Divide by 4096, round up
    
    Status = SystemTable->BootServices->AllocatePages(
        AllocateAddress,
        EfiLoaderData,
        Pages,
        &KernelAddress
    );
    
    if (EFI_ERROR(Status)) {
        SystemTable->ConOut->OutputString(SystemTable->ConOut, L"Error: Cannot allocate kernel memory\r\n");
        KernelFile->Close(KernelFile);
        Root->Close(Root);
        return Status;
    }
    
    // Read kernel into memory
    Status = KernelFile->Read(KernelFile, &KernelSize, (VOID*)KernelAddress);
    if (EFI_ERROR(Status)) {
        SystemTable->ConOut->OutputString(SystemTable->ConOut, L"Error: Cannot read kernel\r\n");
        KernelFile->Close(KernelFile);
        Root->Close(Root);
        return Status;
    }
    
    SystemTable->ConOut->OutputString(SystemTable->ConOut, L"Kernel loaded at: ");
    SystemTable->ConOut->OutputString(SystemTable->ConOut, L"\r\n");
    
    // Close files
    KernelFile->Close(KernelFile);
    Root->Close(Root);
    
    // Get memory map
    UINTN MemoryMapSize = 0;
    UINTN MapKey;
    UINTN DescriptorSize;
    UINT32 DescriptorVersion;
    EFI_MEMORY_DESCRIPTOR *MemoryMap = NULL;
    
    // First get the size
    Status = SystemTable->BootServices->GetMemoryMap(
        &MemoryMapSize,
        MemoryMap,
        &MapKey,
        &DescriptorSize,
        &DescriptorVersion
    );
    
    if (Status != EFI_BUFFER_TOO_SMALL) {
        SystemTable->ConOut->OutputString(SystemTable->ConOut, L"Error: Cannot get memory map size\r\n");
        return Status;
    }
    
    // Allocate memory for map
    MemoryMapSize += 2 * DescriptorSize; // Add some safety margin
    Status = SystemTable->BootServices->AllocatePool(EfiLoaderData, MemoryMapSize, (VOID**)&MemoryMap);
    if (EFI_ERROR(Status)) {
        SystemTable->ConOut->OutputString(SystemTable->ConOut, L"Error: Cannot allocate memory map\r\n");
        return Status;
    }
    
    // Get actual memory map
    Status = SystemTable->BootServices->GetMemoryMap(
        &MemoryMapSize,
        MemoryMap,
        &MapKey,
        &DescriptorSize,
        &DescriptorVersion
    );
    
    if (EFI_ERROR(Status)) {
        SystemTable->ConOut->OutputString(SystemTable->ConOut, L"Error: Cannot get memory map\r\n");
        SystemTable->BootServices->FreePool(MemoryMap);
        return Status;
    }
    
    SystemTable->ConOut->OutputString(SystemTable->ConOut, L"Exiting boot services...\r\n");
    
    // Exit boot services
    Status = SystemTable->BootServices->ExitBootServices(ImageHandle, MapKey);
    if (EFI_ERROR(Status)) {
        SystemTable->ConOut->OutputString(SystemTable->ConOut, L"Error: Cannot exit boot services\r\n");
        SystemTable->BootServices->FreePool(MemoryMap);
        return Status;
    }
    
    SystemTable->ConOut->OutputString(SystemTable->ConOut, L"Jumping to kernel...\r\n");
    
    // Jump to kernel
    void (*KernelEntry)(void) = (void (*)(void))KernelAddress;
    KernelEntry();
    
    // We should never get here
    while (1) {
        __asm__ volatile ("hlt");
    }
    
    return EFI_SUCCESS;
}
