;------------------------------------------------------------------------------
; module: Paging
;
; brief: Interface to the hardware paging mechanism
;
; detail:
; This does not manage memory, see modules PMem and VMem
; /
;------------------------------------------------------------------------------


%ifndef __PAGING_INC__
%define __PAGING_INC__


%ifndef MOD_PAGING


;------------------------------------------------------------------------------
; function: PagingInit
;
; brief: Initializes hardware paging mechanism
;
; pass:
; /
;
; return:
; /
;
; sideeffects:
; /
;
; detail:
; /
;------------------------------------------------------------------------------
[extern PagingInit]


;------------------------------------------------------------------------------
; function: PagingMap
;
; brief: Maps a virtual memory region to a physical region
;
; pass:
;	-> pml4t
;	= virtual address
;	= physical address
;	= region size
;	= options (cache/protection)
; /
;
; return:
; cf	= set if mapping overlaps existing region, clear on success
; /
;
; sideeffects:
; /
;
; detail:
; /
;------------------------------------------------------------------------------
[extern PagingMap]


;------------------------------------------------------------------------------
; function: PagingUnmap
;
; brief: Removes a virtual->physical memory mapped region
;
; pass:
;	-> pml4t
;	= virtual address
;	= region size
; /
;
; return:
; /
;
; sideeffects:
; /
;
; detail:
; /
;------------------------------------------------------------------------------
[extern PagingUnmap]


%endif ;MOD_PAGING


%endif ;__PAGING_INC__
