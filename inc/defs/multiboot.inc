%ifndef __DEFS_MULTIBOOT_H__
%define __DEFS_MULTIBOOT_H__


;------------------------------------------------------------------------------
; Multiboot header definitions

%define MB_PAGEALIGN		0x00000001
%define MB_MEMORYINFO		0x00000002
%define MB_VIDEOTABLE		0x00000004
%define MB_AOUTKLUDGE		0x00010000

%define MB_HEADER_MAGIC		0x1BADB002
%define MB_HEADER_FLAGS		(MB_MEMORYINFO | MB_PAGEALIGN)
%define MB_HEADER_CKSUM		-(MB_HEADER_MAGIC + MB_HEADER_FLAGS)


;------------------------------------------------------------------------------
; Multiboot data structures

struc multiboot_info_t
	.flags			resd 1

	; flags[0]
	.mem_lower		resd 1
	.mem_upper		resd 1

	; flags[1]
	.boot_device		resd 1

	; flags[2]
	.cmdline		resd 1

	; flags[3]
	.mods_count		resd 1
	.mods_addr		resd 1

	; flags[4] | flags[5]
	.syms			resd 4

	; flags[6]
	.mmap_length		resd 1
	.mmap_addr		resd 1

	; flags[7]
	.drives_length		resd 1
	.drives_addr		resd 1

	; flags[8]
	.config_table		resd 1

	; flags[9]
	.boot_loader_name	resd 1

	; flags[10]
	.apm_table		resd 1

	; flags[11]
	.vbe_control_info	resd 1
	.vbe_mode_info		resd 1
	.vbe_mode		resd 1
	.vbe_interface_seg	resd 1
	.vbe_interface_off	resd 1
	.vbe_interface_len	resd 1
endstruc


;------------------------------------------------------------------------------
; Multiboot info structure flags

%define MBINFO_FLAG_MEM			0x00000001
%define MBINFO_FLAG_BOOTDEV		0x00000002
%define MBINFO_FLAG_CMDLINE		0x00000004
%define MBINFO_FLAG_MODS		0x00000008
%define MBINFO_FLAG_SYMS_AOUT		0x00000010
%define MBINFO_FLAG_SYMS_ELF		0x00000020
%define MBINFO_FLAG_MMAP		0x00000040
%define MBINFO_FLAG_DRIVES		0x00000080
%define MBINFO_FLAG_CONFIGTABLE		0x00000100
%define MBINFO_FLAG_BOOTLOADERNAME	0x00000200
%define MBINFO_FLAG_APMTABLE		0x00000400
%define MBINFO_FLAG_VBE			0x00000800


;------------------------------------------------------------------------------
; Memory map entry structure

struc mmap_entry_t
	.size			resd 1
	.base_addr		resq 1
	.length			resq 1
	.type			resd 1
endstruc


;------------------------------------------------------------------------------
; Memory map region types

%define TYPE_FREE			0x01
%define TYPE_RESERVED			0x02
%define TYPE_ACPI_RECLAIMABLE		0x03
%define TYPE_ACPI_NVS			0x04


%endif ;__DEFS_MULTIBOOT_H__
