;------------------------------------------------------------------------------
; module pmem
;
; Physical memory (pageframe) allocator
;------------------------------------------------------------------------------


%ifndef __PMEM_H__
%define __PMEM_H__


%ifndef MOD_PMEM


;------------------------------------------------------------------------------
; function PMemInit
;
; Sets up the pageframe allocaor
;
; pass:
; rbx	-> multiboot data structure (physical address)
;
; return:
; none
;
; notes:
; none
;------------------------------------------------------------------------------
[extern PMemInit]


;------------------------------------------------------------------------------
; function PMemAlloc4k
;
; Allocates a 4kB pageframe
;
; pass:
; none
;
; return:
; cf	= clear on success, set if no available pageframes
; rax	-> pageframe (physical address)
;
; notes:
; none
;------------------------------------------------------------------------------
[extern PMemAlloc4k]


;------------------------------------------------------------------------------
; function PMemAlloc2M
;
; Allocates a 2MB pageframe
;
; pass:
; none
;
; return:
; cf	= clear on success, set if no available pageframes
; rax	-> pageframe (physical address)
;
; notes:
; none
;------------------------------------------------------------------------------
[extern PMemAlloc2M]


;------------------------------------------------------------------------------
; function PMemAllocBlock
;
; Allocates a block of physical pageframes
;
; pass:
; rcx	= requested block size in 4K pageframes
;
; return:
; cf	= clear on success, set if no available pageframes
; rax	-> first pageframe in block (physical address)
; rbx	= allocated block size (see note)
; rcx	= number of requested pageframes not allocated
;
; notes:
; This is for allocating regions of memory that do not have to be physically
; contiguous.
;
; The 'block size' parameter is only a polite suggestion.  This function may
; allocate less or possibly more than requested - check the return value! Rcx
; returns the original requested block size minus the number of blocks
; allocated to set up for repeated calls.  It will return zero in the case
; where the allocated block is larger than requested.
;------------------------------------------------------------------------------
[extern PMemAllocBlock]


;------------------------------------------------------------------------------
; function PMemAllocContig
;
; Allocates a block of physical pageframes
;
; pass:
; rcx	= requested block size in 4K pageframes
;
; return:
; cf	= clear on success, set if no available pageframes
; rax	-> first pageframe in block (physical address)
; rbx	= allocated block size (see note)
;
; notes:
; The 'block size' parameter is only a polite suggestion.  This function may
; allocate more than requested, so check the return value!
;
; Unlike PMemAllocBlock, this will never allocate a block smaller than
; requested.  This is for allocating regions of memory that need to be
; physically contiguous.
;------------------------------------------------------------------------------
[extern PMemAllocContig]


;------------------------------------------------------------------------------
; function PMemFree4K
;
; Frees a 4kB pageframe
;
; pass:
; rax	-> pageframe (physical address)
;
; return:
; none
;
; notes:
; none
;------------------------------------------------------------------------------
[extern PMemFree4K]


;------------------------------------------------------------------------------
; function PMemFree2M
;
; Frees a 2MB pageframe
;
; pass:
; rax	-> pageframe (physical address)
;
; return:
; none
;
; notes:
; none
;------------------------------------------------------------------------------
[extern PMemFree2M]


;------------------------------------------------------------------------------
; function PMemFreeBlock
;
; Frees a block of physical pageframes
;
; pass:
; rax	-> pageframe (physical address)
; rbx	= block size in 4K pageframes
;
; return:
; none
;
; notes:
; This is used to free blocks allocated by both PMemAllocBlock and
; PMemAllocContig.  The size parameter must be the size of the block allocated,
; not the size of the block originally requested.  This is why the return value
; of PMemAllocBlock and PMemAllocContig are important.
;------------------------------------------------------------------------------
[extern PMemFreeBlock]


%endif ;MOD_PMEM


%endif ;__PMEM_H__
