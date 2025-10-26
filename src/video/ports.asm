; src/video/ports.asm
bits 64

global out_byte
global in_byte

; void outb(uint16_t port, uint8_t value)
out_byte:
    mov dx, di    ; port
    mov al, sil   ; value  
    out dx, al
    ret

; uint8_t inb(uint16_t port)
in_byte:
    mov dx, di    ; port
    in al, dx
    ret
