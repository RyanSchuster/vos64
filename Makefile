FILES =	boot/layout boot/entry boot/strapon \
	debug/debug debug/console debug/serial \
	lib/bitmap
#	hal/pmem

BINARY = $(BINDIR)/kernel.bin
LINKSCRIPT = link.ld
OBJECTS = $(FILES:%=$(OBJDIR)/%.o)
SOURCES = $(FILES:%=$(SRCDIR)/%.asm)

SRCDIR = ./src
INCDIR = ./src
BINDIR = ./bin
OBJDIR = $(BINDIR)/obj
MEDIADIR = ./media
DOCDIR = ./scripts/doc

AS = yasm
LINK = ld

ASFLAGS = -i $(INCDIR)/ -f elf64
LINKFLAGS = -T $(LINKSCRIPT) -n

# The whole #!

$(BINARY) : $(OBJECTS) $(LINKSCRIPT)
	$(LINK) $(LINKFLAGS) -o $(BINARY) $(OBJECTS)


# Individual object files


# Entry point and static memory map

$(OBJDIR)/boot/layout.o : $(SRCDIR)/boot/layout.asm $(INCDIR)/boot/layout.inc
	$(AS) $(ASFLAGS) -o $@ $<

$(OBJDIR)/boot/entry.o : $(SRCDIR)/boot/entry.asm
	$(AS) $(ASFLAGS) -o $@ $<

$(OBJDIR)/boot/strapon.o : $(SRCDIR)/boot/strapon.asm $(INCDIR)/boot/strapon.inc $(INCDIR)/boot/layout.inc $(INCDIR)/defs/multiboot.inc $(INCDIR)/defs/pagetab.inc $(INCDIR)/defs/creg.inc $(INCDIR)/defs/msr.inc $(INCDIR)/defs/gdt.inc
	$(AS) $(ASFLAGS) -o $@ $<


# Debugging routines

$(OBJDIR)/debug/debug.o : $(SRCDIR)/debug/debug.asm $(INCDIR)/debug/debug.inc $(INCDIR)/debug/console.inc $(INCDIR)/debug/serial.inc $(INCDIR)/defs/common.inc
	$(AS) $(ASFLAGS) -o $@ $<

$(OBJDIR)/debug/console.o : $(SRCDIR)/debug/console.asm $(INCDIR)/debug/console.inc $(INCDIR)/defs/common.inc
	$(AS) $(ASFLAGS) -o $@ $<

$(OBJDIR)/debug/serial.o : $(SRCDIR)/debug/serial.asm $(INCDIR)/debug/serial.inc
	$(AS) $(ASFLAGS) -o $@ $<


# Generic library routines

$(OBJDIR)/lib/bitmap.o : $(SRCDIR)/lib/bitmap.asm $(INCDIR)/lib/bitmap.inc
	$(AS) $(ASFLAGS) -o $@ $<


# Hardware Abstraction Layer

$(OBJDIR)/hal/pmem.o : $(SRCDIR)/hal/pmem.asm $(INCDIR)/hal/pmem.inc
	$(AS) $(ASFLAGS) -o $@ $<


#$(OBJECTS) : $(SOURCES)
#	$(AS) $(ASFLAGS) -o $@ $<


# Cleanup

.PHONY : clean
clean :
	rm -f $(OBJDIR)/*.o
	rm -f $(OBJDIR)/**/*.o
	rm -f $(BINDIR)/*.bin


# Create bootable media

ISODIR = $(MEDIADIR)/cd/iso
BOOTDIR = $(ISODIR)/boot
GRUB2DIR = $(ISODIR)/boot/grub

.PHONY : install
install : $(MEDIADIR)/cd/vos_boot_cd.iso

$(MEDIADIR)/cd/vos_boot_cd.iso : $(BINARY) $(GRUB2DIR)/*
	cp -f $(BINARY) $(BOOTDIR)
	grub-mkrescue -o $@ $(ISODIR)


# Review code and generate documentation

.PHONY : review
review :
	tools/style.py

.PHONY : dox
dox :
	tools/dox.py
