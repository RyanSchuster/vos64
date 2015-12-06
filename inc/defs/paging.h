%ifndef __DEFS_PAGING_H__
%define __DEFS_PAGING_H__


;Paging structure entry bitfields

%define ENTRY_PRESENT		0x0000000000000001
%define ENTRY_WRITABLE		0x0000000000000002
%define ENTRY_USER		0x0000000000000004
%define ENTRY_WRITETHROUGH	0x0000000000000008
%define ENTRY_UNCACHEABLE	0x0000000000000010
%define ENTRY_ACCESSED		0x0000000000000020
%define ENTRY_PAGE_DIRTY	0x0000000000000040	;ignored if entry is not a page
%define ENTRY_PD_BIGPAGE	0x0000000000000080	;only valid in the PDPT and PDT
%define ENTRY_SMALLPAGE_PAT	0x0000000000000080	;only for 4K pages
%define ENTRY_PAGE_GLOBAL	0x0000000000000100	;only valid if entry is a page
%define ENTRY_OS_0		0x0000000000000200
%define ENTRY_OS_1		0x0000000000000400
%define ENTRY_OS_2		0x0000000000000800
%define ENTRY_BIGPAGE_PAT	0x0000000000001000	;only for large pages

%define ENTRY_MASK_PHYS_4K	0x000FFFFFFFFFF000
%define ENTRY_MASK_PHYS_2M	0x000FFFFFFFE00000
%define ENTRY_MASK_PHYS_1G	0x000FFFFFC0000000


;For computing indexes into paging tables

%define VADDR_PML4_INDEX_MASK	0x0000FF8000000000
%define VADDR_PDPT_INDEX_MASK	0x0000007FC0000000
%define VADDR_PDT_INDEX_MASK	0x000000003FE00000
%define VADDR_PT_INDEX_MASK	0x00000000001FF000

%define VADDR_PML4_INDEX_SHIFT	39
%define VADDR_PDPT_INDEX_SHIFT	30
%define VADDR_PDT_INDEX_SHIFT	21
%define VADDR_PT_INDEX_SHIFT	12

%define STATIC_PML4_INDEX(addr)	((addr & VADDR_PML4_INDEX_MASK) >> VADDR_PML4_INDEX_SHIFT)
%define STATIC_PDPT_INDEX(addr)	((addr & VADDR_PDPT_INDEX_MASK) >> VADDR_PDPT_INDEX_SHIFT)
%define STATIC_PDT_INDEX(addr)	((addr & VADDR_PDT_INDEX_MASK) >> VADDR_PDT_INDEX_SHIFT)
%define STATIC_PT_INDEX(addr)	((addr & VADDR_PT_INDEX_MASK) >> VADDR_PT_INDEX_SHIFT)


%endif ;__DEFS_PAGING_H__
