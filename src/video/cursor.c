#include "video_const.h"
#include "cursor.h"

// form ports.asm
extern uint8_t in_byte(uint16_t port);
extern void out_byte(uint16_t port, uint8_t value);

static uint16_t cursor_x = 0;
static uint16_t cursor_y = 0;

int get_cursor_pos();

void update_cursor()
{
    uint16_t pos = cursor_y * SCREEN_WIDTH + cursor_x;;

    out_byte(VGA_CTRL_REG, CURSOR_LOC_LOW);
    out_byte(VGA_DATA_REG, (uint8_t) ((pos >> 8) & 0xFF));

    out_byte(VGA_CTRL_REG, CURSOR_LOC_HIGH);
    out_byte(VGA_DATA_REG, (uint8_t) (pos & 0xFF));
}
void enable_cursor(uint8_t cursor_start, uint8_t cursor_end)
{
    out_byte(VGA_CTRL_REG, CURSOR_START);
    out_byte(VGA_DATA_REG, (in_byte(VGA_DATA_REG) & 0xC0) | cursor_start);

    out_byte(VGA_CTRL_REG, CURSOR_END);
    out_byte(VGA_DATA_REG, (in_byte(VGA_DATA_REG) & 0xE0) | cursor_end);
}
void disable_cursor()
{
    out_byte(VGA_CTRL_REG, 0x0A);
    out_byte(VGA_DATA_REG, 0x20);
}
void reset_cursor_pos()
{
    cursor_x = 0;
    cursor_y = 0;

    update_cursor();
}
void move_cursor_right()
{
    cursor_x++;
    if(cursor_x > SCREEN_WIDTH)
        move_cursor_newline();
    update_cursor();
}
void move_cursor_newline()
{
    cursor_x = 0;
    cursor_y++;
    update_cursor();
}

int get_raw_cursor_pos()
{
    uint16_t pos;
    
    out_byte(VGA_CTRL_REG, CURSOR_LOC_LOW);
    pos = in_byte(VGA_DATA_REG); // |= to jest or w asm
    out_byte(VGA_CTRL_REG, CURSOR_LOC_HIGH);
    pos |= ((uint16_t)in_byte(VGA_DATA_REG)) << 8; // |= to jest or w asm

    return pos;
}
int get_cursor_pos()
{
    return cursor_y * SCREEN_WIDTH + cursor_x;
}

