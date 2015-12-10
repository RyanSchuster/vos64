%ifndef __DEFS_LAYOUT_H__
%define __DEFS_LAYOUT_H__


%ifndef MOD_LAYOUT


;------------------------------------------------------------------------------
; symbols defined in layout.asm

[extern straponAddr]		; STRAPON_ADDR
[extern remapOffset]		; REMAP_OFFSET
[extern kernAddrPhys]		; KERN_ADDR_PHYS
[extern kernAddrVirt]		; KERN_ADDR_VIRT


%endif ;MOD_LAYOUT


;------------------------------------------------------------------------------
; symbols defined by the linker

[extern kernSize]

[extern text]
[extern data]
[extern bss]
[extern reclaim]
[extern reclaimBss]


;------------------------------------------------------------------------------
; macros to set memory layout

%define STRAPON_ADDR		0x0000000000100000
%define KERN_ADDR_PHYS		0x0000000000200000
%define KERN_ADDR_VIRT		0xFFFFFFFFC0000000

%define REMAP_OFFSET		((KERN_ADDR_VIRT) - (KERN_ADDR_PHYS))


;------------------------------------------------------------------------------
; for converting between physical and virtual addresses

%define STATIC_P_TO_V(addr)	((addr) - REMAP_OFFSET)
%define STATIC_V_TO_P(addr)	((addr) - REMAP_OFFSET)


%endif ;__DEFS_LAYOUT_H__
