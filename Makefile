#
# 
#
#

STAGING_DIR = /opt/devel/openwrt.git/staging_dir/target-arm_v4t_uClibc-0.9.33.2_eabi
CROSS_COMPILE = /opt/devel/openwrt.git/staging_dir/toolchain-arm_v4t_gcc-4.7-linaro_uClibc-0.9.33.2_eabi/bin/arm-openwrt-linux-
AS           = $(CROSS_COMPILE)gcc
CC           = $(CROSS_COMPILE)gcc
LD           = $(CROSS_COMPILE)gcc
GDB          = $(CROSS_COMPILE)gdb
SIZE         = $(CROSS_COMPILE)size
OBJCOPY      = $(CROSS_COMPILE)objcopy
OBJDUMP      = $(CROSS_COMPILE)objdump

all: serial_blaster.o boot-dissassemble.S boot2-dissassemble.S
	gcc -g -o serial_blaster serial_blaster.o

serial_blaster.o: serial_blaster.c
	gcc -g -c -o serial_blaster.o serial_blaster.c

boot-dissassemble.S: boot.bin
	STAGING_DIR=$(STAGING_DIR) $(OBJDUMP) -b binary -m arm7tdmi -z --adjust-vma=0x80014000 -D boot.bin > boot-dissassemble.S

boot.bin: boot.elf
	STAGING_DIR=$(STAGING_DIR) $(OBJCOPY) --output-target binary boot.elf boot.bin

boot.elf: boot.S
	STAGING_DIR=$(STAGING_DIR) $(CC) -mcpu=arm920t -Wall -Wl,-Ttext,0x80014000 -nostdlib -o boot.elf boot.S

boot2-dissassemble.S: boot2.bin
	STAGING_DIR=$(STAGING_DIR) $(OBJDUMP) -b binary -m arm7tdmi -z --adjust-vma=0x300000 -D boot2.bin > boot2-dissassemble.S

boot2.bin: boot2.elf
	STAGING_DIR=$(STAGING_DIR) $(OBJCOPY) --output-target binary boot2.elf boot2.bin

boot2.elf: boot2.S
	STAGING_DIR=$(STAGING_DIR) $(CC) -mcpu=arm920t -Wall -Wl,-Ttext,0x300000 -nostdlib -o boot2.elf boot2.S

clean:
	-rm serial_blaster.o
	-rm boot-dissassemble.S
	-rm boot.bin
	-rm boot.elf
	-rm boot2-dissassemble.S
	-rm boot2.bin
	-rm boot2.elf
	
debug:
	gdb serial_blaster

backup:
	cd .. ; tar cjvf ~/backup/serial_blaster-$(shell date +%F).tar.bz2 serial_blaster


# to make redboot patch:
#
# diff -Naur ts7250-ecos/ rytis-ecos/ >redboot_ts7250_eeprom.diff
#
#