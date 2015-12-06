%define MOD_LAYOUT


%include "layout.h"



; where should we put this strapon? ;)
; this address is both physical and virtual
[global straponAddr]
straponAddr	equ	STRAPON_ADDR


; physical (load) address of the kernel proper
; reclaimable code/data are with the strapon
[global kernAddrPhys]
kernAddrPhys	equ	KERN_ADDR_PHYS


; virtual address of the kernel proper
[global kernAddrVirt]
kernAddrVirt	equ	KERN_ADDR_VIRT


; offset to remap bits into upper memory
[global remapOffset]
remapOffset	equ	REMAP_OFFSET
