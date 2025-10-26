#ifndef COLORING_H
#define COLORING_H

#include "../stdlib/inttypes.h"
#include "video_const.h"


static inline uint8_t vga_color_attribute(vga_color fg, vga_color bg) {
    return (uint8_t)fg | ((uint8_t)(bg | 0x80) << 4); // this | 0x80 should give us a blinking smth but it doeasnt why
}

void set_color_pos(int pos, vga_color fg, vga_color bg);
void set_screen_color(vga_color fg, vga_color bg);
void set_color_from_to(int start_pos, int end_pos, vga_color fg, vga_color bg);
void set_blink_from_to(int start_pos, int end_pos);

#endif
