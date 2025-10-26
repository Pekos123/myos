
[BITS 16]
[ORG 0x7C00]

start:
    ; Set up segments
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    
    ; Load kernel from disk
    mov bx, 0x1000          ; Load kernel at 0x1000
    mov ah, 0x02            ; Read sectors
    mov al, 50              ; Read 50 sectors (25KB)
    mov ch, 0               ; Cylinder 0
    mov cl, 2               ; Start from sector 2
    mov dh, 0               ; Head 0
    int 0x13
    jc disk_error
    
    ; Enable A20 line
    in al, 0x92
    or al, 2
    out 0x92, al
    
    ; Load GDT
    cli
    lgdt [gdt_descriptor]
    
    ; Enter protected mode
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    
    jmp CODE_SEG:protected_mode

disk_error:
    mov si, disk_error_msg
    call print_string
    jmp $

print_string:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp print_string
.done:
    ret

disk_error_msg db "Disk read error!", 0

[BITS 32]
protected_mode:
    ; Set up segments
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000
    
    ; Set up long mode
    ; Disable paging
    mov eax, cr0
    and eax, 0x7FFFFFFF
    mov cr0, eax
    
    ; Set up page tables (identity map first 2MB)
    mov edi, 0x70000
    mov cr3, edi
    xor eax, eax
    mov ecx, 4096
    rep stosd
    mov edi, cr3
    
    ; PML4T[0] -> PDPT
    mov dword [edi], 0x71003
    add edi, 0x1000
    
    ; PDPT[0] -> PDT
    mov dword [edi], 0x72003
    add edi, 0x1000
    
    ; PDT[0] -> 2MB page
    mov dword [edi], 0x00000183
    
    ; Enable PAE
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax
    
    ; Enable long mode
    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr
    
    ; Enable paging
    mov eax, cr0
    or eax, 1 << 31
    mov cr0, eax
    
    ; Load 64-bit GDT
    lgdt [gdt64_descriptor]
    
    jmp CODE64_SEG:long_mode

[BITS 64]
long_mode:
    ; Set up segments
    mov ax, DATA64_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    
    ; Jump to kernel
    jmp 0x1000

; GDT for protected mode
gdt_start:
    dq 0x0000000000000000    ; Null descriptor
gdt_code:
    dq 0x00CF9A000000FFFF    ; Code segment
gdt_data:
    dq 0x00CF92000000FFFF    ; Data segment
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

; GDT for long mode
gdt64_start:
    dq 0x0000000000000000    ; Null descriptor
gdt64_code:
    dq 0x00AF9A000000FFFF    ; 64-bit code segment
gdt64_data:
    dq 0x00AF92000000FFFF    ; 64-bit data segment
gdt64_end:

gdt64_descriptor:
    dw gdt64_end - gdt64_start - 1
    dd gdt64_start

CODE64_SEG equ gdt64_code - gdt64_start
DATA64_SEG equ gdt64_data - gdt64_start

times 510-($-$$) db 0
dw 0xAA55
