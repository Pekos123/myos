#define MULTIBOOT_HEADER_MAGIC 0x1BADB002
#define MULTIBOOT_HEADER_FLAGS 0x0
#define MULTIBOOT_HEADER_CHECKSUM -(MULTIBOOT_HEADER_MAGIC + MULTIBOOT_HEADER_FLAGS)

__attribute__((section(".multiboot")))
const unsigned int multiboot_header[] = {
    MULTIBOOT_HEADER_MAGIC,
    MULTIBOOT_HEADER_FLAGS,
    MULTIBOOT_HEADER_CHECKSUM
};


#include "stdlib/print.h"
#include "video/cursor.h"
#include "video/coloring.h"

void kutas()
{
    print("\n\n");
    print("\n  (:3)");
    print("\n  |  |");
    print("\n  |  |");
    print("\n  |  |");
    print("\n  |  |");
    print("\n  |  |");
    print("\n  |  |");
    print("\n  |  |");
    print("\n  |  |");
    print("\n(______)");
}

void kernel_main() {
    clear_screen();
    enable_cursor(5, 2);

    print("Hi, welcome to Pablo OS :)\n");
    print("Right now to be honest u cant do nothing here, but i will add smth soon :DD");
    
    set_screen_color(BLACK, YELLOW);

    kutas();


    while (1) {
        // have to check if there is anything to do, if not then halt only
        // so we can add blinks into somekind of queue or while
        __asm__ volatile("hlt"); // cpu cant be halted all day long
    }
}
