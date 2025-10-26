/* Minimal linker script for a simple kernel linked to load at physical 1 MiB.
   Adjust ENTRY(name) to match your C entry symbol (e.g. kernel_main or _start).
   Many kernels provide their own assembly startup that calls into C.
*/
OUTPUT_FORMAT("elf64-x86-64")
ENTRY(kernel_main)

SECTIONS
{
    /* Link the kernel to 1MiB physical address (common choice) */
    . = 0x00100000;
    .multiboot : {
        *(.multiboot)
    }
    .text : {
        *(.text.entry)    /* optional explicit entry text */
        *(.text*)         /* all code */
    }

    .rodata : {
        *(.rodata*)
    }

    .data : {
        *(.data*)
    }

    .bss : {
        __bss_start = .;
        *(.bss*)
        *(COMMON)
        __bss_end = .;
    }
    


    /DISCARD/ : { *(.eh_frame*) }
}

/* Provide symbols useful to C code or debugging */
PROVIDE(__kernel_phys_base = 0x00100000);
