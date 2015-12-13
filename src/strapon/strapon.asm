%define MOD_STRAPON
; module: Strapon


%include "strapon/strapon.inc"

%include "layout.inc"
%include "multiboot.inc"
%include "paging.inc"
%include "creg.inc"
%include "msr.inc"
%include "gdt.inc"



[section .straponHeaders noexec write]


align 4
multibootHeader:
	dd	MB_HEADER_MAGIC
	dd	MB_HEADER_FLAGS
	dd	MB_HEADER_CKSUM



[section .straponText exec write]
[bits 32]


[global StraponEntry]
StraponEntry:
	; Set up the stack
	mov	esp, stack

	; Save the multiboot magic and info pointer
	mov	[mbMagic], eax
	mov	[mbInfo], ebx

	; Clear out all of the static paging structures
	; FIXME: is this necessary since they're in bss?
	mov	edi, pml4t
	mov	ecx, 0x400 * 5
	xor	eax, eax
	rep	stosd

	;----- Identity map the 2MB pageframe where the strapon is loaded

	push	STRAPON_ADDR & 0xFFFFFFFF
	push	STRAPON_ADDR >> 32
	push	STRAPON_ADDR & 0xFFFFFFFF
	push	STRAPON_ADDR >> 32
	call	StraponMapPage
	add	esp, 4 * 4

	;----- Higher-half map pages where the kernel is loaded

	mov	ecx, kernSize
	add	ecx, 0x001FFFFF
	shr	ecx, 21

.kernPageLoop:
	push	KERN_ADDR_PHYS & 0xFFFFFFFF
	push	KERN_ADDR_PHYS >> 32
	push	KERN_ADDR_VIRT & 0xFFFFFFFF
	push	KERN_ADDR_VIRT >> 32
	call	StraponMapPage
	add	esp, 4 * 4

	loop	.kernPageLoop

	

	;----- Get into long mode

	; Enable long mode
	mov	ecx, MSR_EFER
	rdmsr
	or	eax, EFER_LME
	wrmsr

	; Enable physical address extension, big pages, and global pages
	mov	eax, cr4
	or	eax, CR4_PSE | CR4_PAE | CR4_PGE
	mov	cr4, eax

	; Set up the pml4 pointer
	mov	eax, pml4t
	mov	cr3, eax

	; Enable paging, protected mode is already enabled
	mov	eax, cr0
	or	eax, CR0_PG
	mov	cr0, eax

	;----- Get into a 64-bit code segment

	lgdt	[gdtp]
	jmp	0x0008:.realm64
.realm64:
	mov	cx, 0x0010
	mov	ds, cx

	[bits 64]

	; Put the machine in a predictable state
	; Leave rax - it's multiboot magic
	; Leave rbx - it's a pointer to multiboot stuff
	mov	rax, [mbMagic]
	mov	rbx, [mbInfo]
	xor	rcx, rcx
	xor	rdx, rdx
	xor	rsi, rsi
	xor	rdi, rdi
	xor	rbp, rbp
	xor	rsp, rsp
	xor	r8, r8
	xor	r9, r9
	xor	r10, r10
	xor	r11, r11
	xor	r12, r12
	xor	r13, r13
	xor	r14, r14
	[extern Entry]
	mov	r15, qword Entry

	; Jump to the entry point of the kernel proper
	; calls: Entry
	jmp	r15
	[bits 32]


;------------------------------------------------------------------------------
; function: StraponAlloc4K
;
; brief: Allocates aligned block of 4KB from the strapon's watermark allocator
;
; pass:
; /
;
; return:
; eax	-> block
; /
;
; sideeffects:
; /
;
; detail:
; This is only the most basic allocator for getting off the ground.  Blocks
; cannot be freed, and allocations only need to be honored as long as the
; strapon's pagetables are being used.
;
; Does no error checking - it's like memory management Lord of the Flies
; /
;------------------------------------------------------------------------------
[bits 32]
StraponAlloc4K:
	mov	eax, [watermark]
	add	eax, 0x00001000
	mov	[watermark], eax
	sub	eax, 0x00001000
	ret


;------------------------------------------------------------------------------
; function: StraponMapPage
;
; brief: Maps a 2M pageframe into virtual memory
;
; pass:
; arg0	= physical address low
; arg1	= physical address high
; arg2	= virtual address low
; arg3	= virtual address high
; /
;
; return:
; /
;
; sideeffects:
; /
;
; detail:
; Uses amd64 paging scheme
;
; Pages are mapped as read/write/execute kernel pages
;
; Will allocate paging table structures if needed
;
; Does no sanity or error checking - it's basically Thunderdome in there
; /
;------------------------------------------------------------------------------
%define VIRT_HI		(ebp + 0x08)
%define VIRT_LO		(ebp + 0x0C)
%define PHYS_HI		(ebp + 0x10)
%define PHYS_LO		(ebp + 0x14)
[bits 32]
StraponMapPage:
	push	ebp
	mov	ebp, esp

	push	eax
	push	ebx
	push	ecx
	push	edx

	;----- Grab a pointer to the PML4

	mov	ebx, pml4t

	;----- Grab a pointer to the PDPT

	; Get the index into the PML4T
	mov	ecx, [VIRT_HI]
	and	ecx, VADDR_PML4_INDEX_MASK >> 32
	shr	ecx, VADDR_PML4_INDEX_SHIFT - 32

	; Grab the entry, check for existence
	mov	eax, [ebx + ecx * 8]
	test	eax, ENTRY_PRESENT
	jnz	.havePDPT

	; Allocate and insert a new PDPT
	call	StraponAlloc4K
	or	eax, ENTRY_PRESENT | ENTRY_WRITABLE
	mov	[ebx + ecx * 8], eax
.havePDPT:
	and	eax, ENTRY_MASK_PHYS_4K & 0xFFFFFFFF
	mov	ebx, eax

	;----- Grab a pointer to the PDT

	; Get the index into the PDPT
	mov	ecx, [VIRT_HI]
	and	ecx, VADDR_PDPT_INDEX_MASK >> 32
	shl	ecx, 32 - VADDR_PDPT_INDEX_SHIFT
	mov	edx, [VIRT_LO]
	and	edx, VADDR_PDPT_INDEX_MASK & 0xFFFFFFFF
	shr	edx, VADDR_PDPT_INDEX_SHIFT
	or	ecx, edx

	; Grab the entry, check for existence
	mov	eax, [ebx + ecx * 8]
	test	eax, ENTRY_PRESENT
	jnz	.havePDT

	; Allocate and insert a new PDT
	call	StraponAlloc4K
	or	eax, ENTRY_PRESENT | ENTRY_WRITABLE
	mov	[ebx + ecx * 8], eax
.havePDT:
	and	eax, ENTRY_MASK_PHYS_4K & 0xFFFFFFFF
	mov	ebx, eax

	;----- Point the PDT entry at the 2M page

	; Get the index into the PDT
	mov	ecx, [VIRT_LO]
	and	ecx, VADDR_PDT_INDEX_MASK
	shr	ecx, VADDR_PDT_INDEX_SHIFT

	; Store physical address and flags
	mov	eax, [PHYS_LO]
	mov	edx, [PHYS_HI]
	and	eax, ENTRY_MASK_PHYS_2M & 0xFFFFFFFF
	or	eax, ENTRY_PRESENT | ENTRY_WRITABLE | ENTRY_PD_BIGPAGE
	mov	[ebx + ecx * 8], eax
	and	edx, ENTRY_MASK_PHYS_2M >> 32
	mov	[ebx + ecx * 8 + 4], edx

	pop	edx
	pop	ecx
	pop	ebx
	pop	eax
	pop	ebp
	ret


;------------------------------------------------------------------------------
; Ancient code for identity-mapping lower 2M and higher-half the second 2M
; here for reference in case something breaks
; TODO: delete this once it's been committed to a git repo

	;----- Identity map the 2MB pageframe where the strapon is loaded

	; The " & 0xFFFFFFFF"s are to supress warnings.  The upper dwords of
	; addresses will always be 0s, so it's safe to ignore these bits.

	; Point the pml4t entry at the pdpt
	;mov	eax, pdptLow
	;and	eax, ENTRY_MASK_PHYS_4K & 0xFFFFFFFF
	;or	eax, ENTRY_PRESENT | ENTRY_WRITABLE
	;mov	[pml4t + (STATIC_PML4_INDEX(STRAPON_ADDR) * 8)], eax

	; Point the pdpt entry at the pdt
	;mov	eax, pdtLow
	;and	eax, ENTRY_MASK_PHYS_4K & 0xFFFFFFFF
	;or	eax, ENTRY_PRESENT | ENTRY_WRITABLE
	;mov	[pdptLow + (STATIC_PDPT_INDEX(STRAPON_ADDR) * 8)], eax

	; Point the pdt entry at the large page
	;mov	eax, (STRAPON_ADDR & ENTRY_MASK_PHYS_2M) | ENTRY_PRESENT | ENTRY_WRITABLE | ENTRY_PD_BIGPAGE
	;mov	[pdtLow + (STATIC_PDT_INDEX(STRAPON_ADDR) * 8)], eax

	;----- Higher-half map two MBs where the kernel is loaded

	; Point the pml4t entry at the pdpt
	;mov	eax, pdptHigh
	;and 	eax, ENTRY_MASK_PHYS_4K & 0xFFFFFFFF
	;or	eax, ENTRY_PRESENT | ENTRY_WRITABLE
	;mov	[pml4t + (STATIC_PML4_INDEX(KERN_ADDR_VIRT) * 8)], eax

	; Point the pdpt entry at the pdt
	;mov	eax, pdtHigh
	;and	eax, ENTRY_MASK_PHYS_4K & 0xFFFFFFFF
	;or	eax, ENTRY_PRESENT | ENTRY_WRITABLE
	;mov	[pdptHigh + (STATIC_PDPT_INDEX(KERN_ADDR_VIRT) * 8)], eax

	; Point the pdt entry at the large page
	;mov	eax, (KERN_ADDR_PHYS & ENTRY_MASK_PHYS_2M) | ENTRY_PRESENT | ENTRY_WRITABLE | ENTRY_PD_BIGPAGE
	;mov	[pdtHigh + (STATIC_PDT_INDEX(KERN_ADDR_VIRT) * 8)], eax

;------------------------------------------------------------------------------



[section .straponData write]


align 8
gdt:
.null:
	dq	GDTE_NULL
.code:
	dq	GDTE_CODE_CPL0
.data:
	dq	GDTE_DATA_CPL0
.size:

gdtp:
	dw	0x0018		; FIXME: use gdt size label
	dq	gdt

watermark:
	dd	freemem



[section .straponBss noprogbits write]


mbMagic:
	resq	1
mbInfo:
	resq	1

align 0x1000
pml4t:
	resb	0x1000

pdptLow:
	resb	0x1000

pdptHigh:
	resb	0x1000

pdtLow:
	resb	0x1000

pdtHigh:
	resb	0x1000

	resb	0x1000
stack:

freemem:
	resb	0x1000 * 32
