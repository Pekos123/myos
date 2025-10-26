[BITS 64]
[ORG 0]

; UEFI Application Header
section .text
efi_header:
    ; PE header
    db 0x4D, 0x5A, 0x90, 0x00, 0x03, 0x00, 0x00, 0x00
    db 0x04, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0x00, 0x00
    db 0xB8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    db 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    
    ; PE signature
    db 0x50, 0x45, 0x00, 0x00
    
    ; Basic PE fields
    dw 0x8664                   ; Machine (x86-64)
    dw 0x0001                   ; Number of sections
    dd 0x00                     ; Timestamp
    dd 0x00                     ; Pointer to symbol table
    dd 0x00                     ; Number of symbols
    dw efi_optional_header_end - efi_optional_header ; Size of optional header
    dw 0x0206                   ; Characteristics (executable image)

efi_optional_header:
    dw 0x020B                   ; Magic (PE32+)
    db 0x00                     ; Major linker version
    db 0x00                     ; Minor linker version
    dd 0x00                     ; Size of code
    dd 0x00                     ; Size of initialized data
    dd 0x00                     ; Size of uninitialized data
    dd _start                   ; Entry point
    dd 0x00                     ; Base of code
    
    dq 0x00                     ; Image base
    dd 0x200                    ; Section alignment
    dd 0x200                    ; File alignment
    dw 0x00                     ; Major OS version
    dw 0x00                     ; Minor OS version
    dw 0x00                     ; Major image version
    dw 0x00                     ; Minor image version
    dw 0x05                     ; Major subsystem version
    dw 0x00                     ; Minor subsystem version
    dd 0x00                     ; Win32 version value
    dd _end - efi_header        ; Size of image
    dd efi_header               ; Size of headers
    dd 0x00                     ; Checksum
    dw 0x000A                   ; Subsystem (EFI application)
    dw 0x00                     ; DLL characteristics
    dq 0x00                     ; Size of stack reserve
    dq 0x00                     ; Size of stack commit
    dq 0x00                     ; Size of heap reserve
    dq 0x00                     ; Size of heap commit
    dd 0x00                     ; Loader flags
    dd 0x00                     ; Number of RVA and sizes

efi_optional_header_end:

; Simple bootloader that just jumps to kernel
_start:
    ; UEFI passes SystemTable in RDX
    mov rdi, rdx                ; Pass SystemTable to kernel if needed
    
    ; Jump to kernel at 1MB
    mov rax, 0x100000
    jmp rax

_end:
