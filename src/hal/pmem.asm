%define MOD_PMEM
; module: PMem


%include "hal/pmem.inc"

%include "lib/bitmap.inc"
%include "defs/multiboot.inc"

%include "debug/debug.inc"



struc region_t
	; Bookkeeping for this region
	prev		resq 1	; list of all regions (replace with tree?)
	next		resq 1
	lock		resq 1	; for multiprocessor use
	basePageAddr	resq 1	; address of first pageframe in the region

	; Supermap of 2MB pageframes
	bigpageMap	resq 1	; pointer to wordmap of 2MB pageframes
	bigpageMapSize	resq 1	; wordmap size in qwords
	bigpageStart	resq 1	; qword to start scanning (for speed)
	bigpageFree	resq 1	; number of free big (2MB) pageframes
	bigpagePrev	resq 1	; list of regions with free bigpages
	bigpageNext	resq 1

	; Map of 4kB pageframes
	pageMap		resq 1	; pointer to bitmap of 4kB pageframes
	pageMapSize	resq 1	; bitmap size in qwords
	pageStart	resq 1	; qword to start scanning (for speed)
	pageFree	resq 1	; number of free 4kB pageframes
	pagePrev	resq 1	; list of regions with free pages
	pageNext	resq 1
endstruc



[section .text]
[bits 64]


[global PMemInit]
PMemInit:
	; Initialize the good-enough region structure
	mov	rdi, pmemRegionRoot
	xor	rcx, rcx

	mov	[rdi + region_t.prev], rcx
	mov	[rdi + region_t.next], rcx
	mov	[rdi + region_t.lock], rcx
	mov	[rdi + region_t.basePageAddr], rcx

	mov	rdx, pmemRootBytemap
	mov	[rdi + region_t.bigpageMap], rdx
	mov	rdx, (1 * 4096) / 8
	mov	[rdi + region_t.bigpageMapSize], rdx
	mov	[rdi + region_t.bigpageStart], rcx
	mov	[rdi + region_t.bigpageFree], rcx
	mov	[rdi + region_t.bigpagePrev], rcx
	mov	[rdi + region_t.bigpageNext], rcx

	mov	rdx, pmemRootBitmap
	mov	[rdi + region_t.pageMap], rdx
	mov	rdx, (32 * 4096) / 8
	mov	[rdi + region_t.pageMapSize], rdx
	mov	[rdi + region_t.pageStart], rcx
	mov	[rdi + region_t.pageFree], rcx
	mov	[rdi + region_t.pagePrev], rcx
	mov	[rdi + region_t.pageNext], rcx

	cld
	mov	rdi, pmemRootBytemap
	mov	rcx, (1 * 4096) / 8
	xor	rax, rax		; zeros (number of free pageframes)
	rep	stosq
	mov	rdi, pmemRootBitmap
	mov	rcx (32 * 4096) / 8
	not	rax			; ones (all pageframes in use)
	rep	stosq

	; Check for the existence of the memory map
	mov	eax, [rbx + multiboot_info_t.flags]
	test	eax, MBINFO_FLAG_MMAP
	jz	.noMMap

	; Start traversing the memory map
	xor	rax, rax
	xor	rcx, rcx
	mov	eax, [rbx + multiboot_info_t.mmap_addr]
	mov	ecx, [rbx + multiboot_info_t.mmap_length]
	add	rcx, rax
	xor	rdx, rdx
.mapLoop:
	mov	ebx, [rax + mmap_entry_t.type]	; only a dword
	cmp	ebx, TYPE_FREE
	jne	.mapNext

	; Have a free region, mark in the bitmap
	call	PMemFreeBlock

.mapNext:
	; Keep track of the high watermark
	;mov	rbx, [rax + mmap_entry_t.base_addr]
	;add	rbx, [rax + mmap_entry_t.length]
	;cmp	rbx, rdx
	;cmova	rdx, rbx

	; Next map region
	add	eax, [rax + mmap_entry_t.size]
	add	rax, 0x00000004
	cmp	rax, rcx
	jb	.mapLoop

	;PRINT	"Memory high watermark:"
	;PRINTQ	rdx

	ret

	; No memory map present, try to use memory fields
.noMMap:
	test	eax, MBINFO_FLAG_MEM
	jz	.fail

	; Use memory info
	PRINT	"No E820 map, using mem info"
	PRINT	"Not yet, LOL."
	cli
	hlt

.fail:
	PRINT	"PANIC: No memory info found!"
	cli
	hlt


[global PMemAlloc4K]
PMemAlloc4K:
	ret


[global PMemAlloc2M]
PMemAlloc2M:
	ret


[global PMemAllocBlock]
PMemAllocBlock:
	ret


[global PMemAllocContig]
PMemAllocCont:
	ret


[global PMemFree4K]
PMemFree4K:
	push	rax
	push	rcx
	push	rsi
	push	rdi

	; Find the appropriate region and adjust the address
	call	PMemFindRegion

	; Clear the bit in the 4kB pageframe bitmap
	shr	rax, 12			; change to 4k page index
	mov	rsi, [rdi + region_t.pageMap]
	mov	rcx, [rdi + region_t.pageMapSize]
	call	BitmapBitClear

	; Increment the counter in the 2MB pageframe wordmap
	shr	rax, 9			; change to 2M page index
	mov	rsi, [rdi + region_t.bigpageMap]
	inc	word [rdi + rax * 2]

	pop	rdi
	pop	rsi
	pop	rcx
	pop	rax
	ret


[global PMemFree2M]
PMemFree2M:
	push	rax
	push	rbx
	push	rcx
	push	rsi
	push	rdi

	call	PMemFindRegion

	; Find the appropriate region and adjust the address
	call	PMemFindRegion

	; Clear the bits in the 4kB pageframe bitmap
	shr	rax, 12			; change to 4k page index
	mov	rsi, [rdi + region_t.pageMap]
	mov	rcx, [rdi + region_t.pageMapSize]
	mov	rbx, 512		; 4k pageframes per 2M pageframe
	call	BitmapRangeClear

	; Reset the counter in the 2MB pageframe wordmap
	shr	rax, 9			; change to 2M page index
	mov	rsi, [rdi + region_t.bigpageMap]
	mov	word [rdi + rax * 2], bx

	pop	rdi
	pop	rsi
	pop	rcx
	pop	rbx
	pop	rax
	ret


[global PMemFreeBlock]
PMemFreeBlock:
	call	PMemFindRegion

	ret


; = start 4K pageframe
; = number of 4K pageframes
PMemClearSupermap:
	ret


PMemSetSupermap:
	ret


;------------------------------------------------------------------------------
; function: PMemFindRegion
;
; brief: Finds a region?
;
; pass:
; rax	= start 4K pageframe address
; /
;
; return:
; cf	= set on error, clear on success
; rdi	-> region
; rax	= offset into region (still byte-aligned)
; /
;
; sideeffects:
; /
;
; detail:
; /
;------------------------------------------------------------------------------
PMemFindRegion:
	; TODO: scan through list of regions
	; this is here as a placeholder for now so the hooks are in place
	; for later
	mov	rdi, pmemRegionRoot
	sub	rax, [rdi + region_t.basePageAddr]
	clc

	ret



[section .data]



[section .bss]


; Good enough for now - single region of 4GB

pmemRegionRoot:
	resb	region_t_size

pmemRootBytemap:
	resb	1 * 4096

pmemRootBitmap:
	resb	32 * 4096
