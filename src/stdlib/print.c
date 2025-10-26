#include "../const.h"
#include "../video/cursor.h"
#include "../video/video_const.h"
#include "../video/coloring.h"

void clear_screen() {
    // Clear screen first
    for (int i = 0; i < SCREEN_WIDTH * SCREEN_HEIGHT * 2; i += 2) {
        VIDEO_MEMORY[i] = ' ';      // Character at even offsets
        VIDEO_MEMORY[i + 1] = 0x07; // Color at odd offsets
    }
    
    reset_cursor_pos();
}
static char toStrBuffer[12];
void clearStrBuffer()
{
    for(int i = 0; i < 12; i++)
    {
        toStrBuffer[i] = '\0';
    }
}
char* to_string(int num)
{
    clearStrBuffer();

    char buffer[12];

    int i = 0;
    BOOL isNegative = FALSE;
    if(num < 0)
    {
        num = -num;
        isNegative = TRUE;
    }
    else if(num == 0)
    {
        toStrBuffer[0] = '0';
        toStrBuffer[1] = '\0';
        return toStrBuffer;
    }

    while(num > 0)
    {
        int digit = num % 10;
        num /= 10;
        buffer[i] = digit + 48; // ASCII char: 0 = 48
        i++;
    }
    if(isNegative)
    {
        buffer[i] = '-';
        i++;
    }
    buffer[i] = '\0';
    
    for(int j = 0; j < i; j++)
    {
        toStrBuffer[j] = buffer[i-j-1];
    }

    return toStrBuffer;
}

void print(char* string) {
    int i = 0;
    while (string[i] != '\0') {
        if (string[i] == '\n') {
            move_cursor_newline();
        } else {
            // Write character and attribute
            int pos = get_cursor_pos();
            int memory_offset = pos * 2;
            VIDEO_MEMORY[memory_offset] = string[i];
            move_cursor_right();
        }
        i++;
        
        // Check for screen bounds
        if (get_cursor_pos() >= SCREEN_WIDTH * SCREEN_HEIGHT * 2) {
            // Implement scrolling or reset position
            reset_cursor_pos();
        }
    }
}
void print_error(char* error_msg)
{
    int start_pos = get_cursor_pos() * 2;
    {
        print("KERNEL ERROR: ");
        print(error_msg);
    }
    int end_pos = get_cursor_pos() * 2;
    set_color_from_to(start_pos, end_pos, WHITE, RED);
    set_blink_from_to(start_pos, end_pos);
}
