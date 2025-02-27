BOCHS = bochs/bin
OUT_DIR = out
DISK_PATH = c.img

CC=clang
CSFLAGS= -S -m32 -O3 -masm=intel -nostdlib -fno-builtin
CCFLAGS= -c -m32 -O3 -nostdlib -ffunction-sections -fdata-sections -fno-builtin -ffreestanding
ASM=nasm
ASMFLAGS= -f elf32

CMP_DIRS=lib kernel device fs shell
SCH_DIRS = $(shell find $(CMP_DIRS) -maxdepth 9 -type d)
OUT_CRT_DIRS+=$(foreach dir, $(SCH_DIRS), $(OUT_DIR)/$(dir) )
SRCS_C += $(foreach dir, $(SCH_DIRS), $(wildcard $(dir)/*.c))
SRCS_ASM += $(foreach dir, $(SCH_DIRS), $(wildcard $(dir)/*.asm))
ASMS_C +=$(patsubst %.c, %.s, $(SRCS_C))
OBJS_C +=$(patsubst %.c, %.o, $(SRCS_C))
OBJS_ASM +=$(patsubst %.asm, %.o, $(SRCS_ASM))

KERNEL_ENTRY= kernel/main.c
KERNEL_ENTRY_OBJ= $(OUT_DIR)/kernel/main.o
OBJS_OUT_ALL0+=$(foreach dir, $(OBJS_C), $(OUT_DIR)/$(dir) )
OBJS_OUT_ALL0+=$(foreach dir, $(OBJS_ASM), $(OUT_DIR)/$(dir) )
OBJS_OUT_ALL=$(filter-out $(KERNEL_ENTRY_OBJ),$(OBJS_OUT_ALL0))

all:$(OBJS_C)  $(OBJS_ASM)

loader: include/boot.inc loader.asm mbr.asm
	nasm mbr.asm -I ./include -o ${OUT_DIR}/mbr.bin
	nasm loader.asm -I ./include -o ${OUT_DIR}/loader.bin

make_out_dir:
	mkdir -p $(OUT_DIR)
	for x in $(OUT_CRT_DIRS); do \
		mkdir -p $$x; \
	done

$(OBJS_C):%.o : %.c
	$(CC) $(CCFLAGS) $^ -o $(OUT_DIR)/$@
	$(CC) $(CSFLAGS) $^ -o $(OUT_DIR)/$@.s

$(OBJS_ASM):%.o : %.asm $(make_out_dir)
	$(ASM) $(ASMFLAGS) $? -o $(OUT_DIR)/$@

link:$(OBJS_C) $(OBJS_ASM)
	ld.lld -m elf_i386   -Ttext 0xc0001500   --gc-sections -e main   $(KERNEL_ENTRY_OBJ) --start-group ${OBJS_OUT_ALL} --end-group -o $(OUT_DIR)/kernel.bin

copy_to_disk: make_out_dir link loader
	dd if=${OUT_DIR}/mbr.bin of=${DISK_PATH} bs=512 count=1 conv=notrunc
	dd if=${OUT_DIR}/loader.bin of=${DISK_PATH} seek=2 bs=512 count=4 conv=notrunc
	dd if=${OUT_DIR}/kernel.bin of=${DISK_PATH} seek=9 bs=512 count=200 conv=notrunc


start:copy_to_disk
	${BOCHS}/bochs -q

clean:
	rm -rf $(OUT_DIR)
