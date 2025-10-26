# Simple x86_64 OS Makefile

ASM = nasm
CC = gcc
LD = ld

ASMFLAGS = -f elf64
CFLAGS = -m64 -ffreestanding -fno-pie -nostdlib -nostdinc -mno-red-zone -fno-stack-protector -O2
LDFLAGS = -m elf_x86_64 -T src/linkerScript.ld

# Directories
BOOTLOADER_DIR = bootloader
SRC_DIR = src
BUILD_DIR = build
BIN_DIR = bin
OBJ_DIR = obj

# Source files - Add your .c and .asm files here
C_SOURCES = $(wildcard $(SRC_DIR)/*.c) \
            $(wildcard $(SRC_DIR)/**/*.c)

# Find all .asm files EXCEPT kernel_entry.asm (it's handled separately)
ASM_SOURCES = $(filter-out $(SRC_DIR)/kernel_entry.asm, \
              $(wildcard $(SRC_DIR)/*.asm) \
              $(wildcard $(SRC_DIR)/**/*.asm))

# Object files
KERNEL_ENTRY_O = $(OBJ_DIR)/kernel_entry.o
C_OBJECTS = $(patsubst $(SRC_DIR)/%.c, $(OBJ_DIR)/%.o, $(C_SOURCES))
ASM_OBJECTS = $(patsubst $(SRC_DIR)/%.asm, $(OBJ_DIR)/%.o, $(ASM_SOURCES))

# Binary files
BOOT_BIN = $(BIN_DIR)/boot.bin
KERNEL_ELF = $(BUILD_DIR)/kernel.elf
KERNEL_BIN = $(BIN_DIR)/kernel.bin
OS_BIN = $(BIN_DIR)/os.bin

.PHONY: all clean dirs

all: dirs $(OS_BIN)

dirs:
	@mkdir -p $(BUILD_DIR) $(BIN_DIR) $(OBJ_DIR) $(OBJ_DIR)/stdlib $(OBJ_DIR)/video

$(BOOT_BIN): $(BOOTLOADER_DIR)/boot.asm
	@echo "Assembling bootloader..."
	$(ASM) -f bin $< -o $@

$(KERNEL_ENTRY_O): $(SRC_DIR)/kernel_entry.asm
	@echo "Assembling kernel entry..."
	$(ASM) $(ASMFLAGS) $< -o $@

# Pattern rule for C files
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	@echo "Compiling $<..."
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

# Pattern rule for ASM files
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.asm
	@echo "Assembling $<..."
	@mkdir -p $(dir $@)
	$(ASM) $(ASMFLAGS) $< -o $@

$(KERNEL_ELF): $(KERNEL_ENTRY_O) $(C_OBJECTS) $(ASM_OBJECTS)
	@echo "Linking kernel..."
	$(LD) $(LDFLAGS) -o $@ $^

$(KERNEL_BIN): $(KERNEL_ELF)
	@echo "Creating kernel binary..."
	objcopy -O binary $< $@

$(OS_BIN): $(BOOT_BIN) $(KERNEL_BIN)
	@echo "Creating OS image..."
	cat $(BOOT_BIN) $(KERNEL_BIN) > $@
	@echo "Build complete!"
	@echo "C files: $(C_SOURCES)"
	@echo "ASM files: $(ASM_SOURCES)"

clean:
	@echo "Cleaning build files..."
	rm -rf $(BUILD_DIR) $(BIN_DIR) $(OBJ_DIR)
	@echo "Clean complete!"
