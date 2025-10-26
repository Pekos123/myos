#ifndef VIDEO_CONST_H
#define VIDEO_CONST_H

#define SCREEN_WIDTH 80
#define SCREEN_HEIGHT 25

// ----- CURSOR ------
// VGA registers
#define VGA_CTRL_REG 0x3D4
#define VGA_DATA_REG (uint8_t)0x3D5

#define CURSOR_LOC_HIGH 0x0E
#define CURSOR_LOC_LOW  0x0F
#define CURSOR_START    0x0A
#define CURSOR_END      0x0B



#define VIDEO_MEMORY ((volatile char*)0xB8000)
//volatile char* VIDEO_MEMORY = ((volatile char*)0xB8000);

// VGA colors
typedef enum{
    BLACK = 0,
    BLUE = 1,
    GREEN = 2,
    CYAN = 3,
    RED = 4,
    MAGENTA = 5,
    BROWN = 6,
    LIGHT_GREY = 7,
    DARK_GREY = 8,
    LIGHT_BLUE = 9,
    LIGHT_GREEN = 10,
    LIGHT_CYAN = 11,
    LIGHT_RED = 12,
    LIGHT_MAGENTA = 13,
    YELLOW = 14,
    WHITE = 15
}vga_color;

#endif
