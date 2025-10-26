[BITS 64]
global _start
extern kernel_main

section .text
_start:
    ; Clear direction flag
    cld
    
    ; Set up stack
    mov rsp, stack_top
    
    ; Call kernel main
    call kernel_main
    
    ; If kernel returns, halt forever
    cli
.halt:
    hlt
    jmp .halt

section .bss
align 16
stack_bottom:
    resb 16384  ; 16KB stack
stack_top:
