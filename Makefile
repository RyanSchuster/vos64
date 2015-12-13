FILES =	layout entry \
	strapon/strapon \
	debug/debug debug/console debug/serial \
	lib/bitmap
#	hal/pmem

BINARY = $(BINDIR)/kernel.bin
LINKSCRIPT = link.ld
OBJECTS = $(FILES:%=$(OBJDIR)/%.o)
SOURCES = $(FILES:%=$(SRCDIR)/%.asm)

SRCDIR = ./src
INCDIR = ./inc
OBJDIR = ./obj
BINDIR = ./bin
MEDIADIR = ./media
DOCDIR = ./doc

AS = yasm
LINK = ld

ASFLAGS = -i $(INCDIR)/ -f elf64
LINKFLAGS = -T $(LINKSCRIPT) -n

# The whole #!

$(BINARY) : $(OBJECTS) $(LINKSCRIPT)
	$(LINK) $(LINKFLAGS) -o $(BINARY) $(OBJECTS)


# Individual object files


# Static memory map symbols

$(OBJDIR)/layout.o : $(SRCDIR)/layout.asm $(INCDIR)/layout.inc
	$(AS) $(ASFLAGS) -o $@ $<


# Entry point for kernel-proper

$(OBJDIR)/entry.o : $(SRCDIR)/entry.asm
	$(AS) $(ASFLAGS) -o $@ $<


# Strapon bootloader stage

$(OBJDIR)/strapon/strapon.o : $(SRCDIR)/strapon/strapon.asm $(INCDIR)/strapon/strapon.inc $(INCDIR)/layout.inc $(INCDIR)/multiboot.inc $(INCDIR)/paging.inc $(INCDIR)/creg.inc $(INCDIR)/msr.inc $(INCDIR)/gdt.inc
	$(AS) $(ASFLAGS) -o $@ $<


# Debugging routines

$(OBJDIR)/debug/debug.o : $(SRCDIR)/debug/debug.asm $(INCDIR)/debug/debug.inc $(INCDIR)/debug/console.inc $(INCDIR)/debug/serial.inc $(INCDIR)/defs.inc
	$(AS) $(ASFLAGS) -o $@ $<

$(OBJDIR)/debug/console.o : $(SRCDIR)/debug/console.asm $(INCDIR)/debug/console.inc $(INCDIR)/defs.inc
	$(AS) $(ASFLAGS) -o $@ $<

$(OBJDIR)/debug/serial.o : $(SRCDIR)/debug/serial.asm $(INCDIR)/debug/serial.inc
	$(AS) $(ASFLAGS) -o $@ $<


# Generic library routines

$(OBJDIR)/lib/bitmap.o : $(SRCDIR)/lib/bitmap.asm $(INCDIR)/lib/bitmap.inc
	$(AS) $(ASFLAGS) -o $@ $<


# Hardware Abstraction Layer

obj/hal/pmem.o : $(SRCDIR)/hal/pmem.asm $(INCDIR)/hal/pmem.inc
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
	python review.py

.PHONY : dox
dox :
	scripts/ScanTree.py
