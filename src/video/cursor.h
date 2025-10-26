#ifndef CURSOR_H
#define CURSOR_H

#include "../stdlib/inttypes.h"

void update_cursor(void);
void reset_cursor_pos(void);

void move_cursor_right(void);
void move_cursor_newline(void);

void enable_cursor(uint8_t cursor_start, uint8_t cursor_end);
int get_cursor_pos(void);
int get_raw_cursor_pos(void);

#endif
