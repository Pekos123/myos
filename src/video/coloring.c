#include "coloring.h"
#include "../stdlib/print.h"
#include "cursor.h"


void set_color_pos(int pos, vga_color fg, vga_color bg)
{
    if((pos+1) % 2 == 0)
    {
        print("\n\n");
        print_error("CANT CHANGE COLOR AT GIVEN POS"); // write some kind of char formater for this 
        print("\n\n");

    }
    else VIDEO_MEMORY[pos+1] = vga_color_attribute(fg, bg);
}

void set_color_from_to(int start_pos, int end_pos, vga_color fg, vga_color bg)
{
    for(int i = start_pos; i < end_pos; i++)
    {
        VIDEO_MEMORY[i+1] = vga_color_attribute(fg, bg);
        i++;
    }
}

void set_screen_color(vga_color fg, vga_color bg)
{
    int max = SCREEN_HEIGHT * SCREEN_WIDTH * 2;
    for(int i = 0; i < max; i++)
    {
        VIDEO_MEMORY[i+1] = vga_color_attribute(fg, bg);
        i++;
    }
}
void set_blink_from_to(int start_pos, int end_pos)
{
    for(int i = start_pos; i < end_pos; i++)
    {
        VIDEO_MEMORY[i+1];
        i++;
    }
}
