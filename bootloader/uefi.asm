[BITS 64]
[ORG 0]

section .text

; DOS Header
db 0x4D, 0x5A                   ; Magic number
times 58 db 0                   ; Fill rest of DOS header
dd 0x00004550                   ; PE signature

; COFF Header
dw 0x8664                       ; Machine (x86-64)
dw 0                            ; Number of sections
dd 0                            ; Timestamp
dd 0                            ; Pointer to symbol table
dd 0                            ; Number of symbols
dw 0x00E0                       ; Size of optional header
dw 0x206                        ; Characteristics

; Optional Header
dw 0x20B                        ; Magic (PE32+)
db 0                            ; Major linker version
db 0                            ; Minor linker version
dd 0                            ; Size of code
dd 0                            ; Size of initialized data
dd 0                            ; Size of uninitialized data
dd start                        ; Entry point
dd 0                            ; Base of code

; Windows Specific Fields
dq 0x0000000000400000           ; Image base
dd 0x200                        ; Section alignment
dd 0x200                        ; File alignment
dw 0                            ; Major OS version
dw 0                            ; Minor OS version
dw 0                            ; Major image version
dw 0                            ; Minor image version
dw 5                            ; Major subsystem version
dw 0                            ; Minor subsystem version
dd 0                            ; Win32 version value
dd _end                         ; Size of image
dd 0x200                        ; Size of headers
dd 0                            ; Checksum
dw 0xA                          ; Subsystem (EFI application)
dw 0                            ; DLL characteristics
dq 0x10000                      ; Size of stack reserve
dq 0x1000                       ; Size of stack commit
dq 0x10000                      ; Size of heap reserve
dq 0x0                          ; Size of heap commit
dd 0                            ; Loader flags
dd 0                            ; Number of RVA and sizes

; Data directories (all zero for EFI)
times 16 dq 0

; Entry point
start:
    ; Simple: jump to kernel at 1MB
    mov rax, 0x100000
    jmp rax

; Padding to make file size reasonable
times 512 - ($ - $$) db 0

_end:
