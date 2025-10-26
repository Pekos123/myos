[BITS 64]
global _start
extern kernel_main

section .text
_start:
    ; Set up stack
    mov rsp, stack_top
    
    ; Clear direction flag
    cld
    
    ; Call kernel main
    call kernel_main
    
    ; Halt if kernel returns
    cli
.halt:
    hlt
    jmp .halt

section .bss
align 16
stack_bottom:
    resb 16384  ; 16KB stack
stack_top:
