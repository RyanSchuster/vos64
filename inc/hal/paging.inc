;------------------------------------------------------------------------------
; module paging
;
; Interface to the hardware paging mechanism
;
; This does not manage memory, see modules PMem and VMem
;------------------------------------------------------------------------------


%ifndef __PAGING_H__
%define __PAGING_H__


%ifndef MOD_PAGING


;------------------------------------------------------------------------------
; function PagingInit
;
; Initializes hardware paging mechanism
;
; pass:
; none
;
; return:
; none
;
; notes:
; none
;------------------------------------------------------------------------------
[extern PagingInit]


;------------------------------------------------------------------------------
; function PagingMap
;
; Maps a virtual memory region to a physical region
;
; pass:
;	-> pml4t
;	= virtual address
;	= physical address
;	= region size
;	= options (cache/protection)
;
; return:
; cf	= set if mapping overlaps existing region, clear on success
;
; notes:
; none
;------------------------------------------------------------------------------
[extern PagingMap]


;------------------------------------------------------------------------------
; function PagingUnmap
;
; Removes a virtual->physical memory mapped region
;
; pass:
;	-> pml4t
;	= virtual address
;	= region size
;
; return:
; none
;
; notes:
; none
;------------------------------------------------------------------------------
[extern PagingUnmap]


%endif ;MOD_PAGING


%endif ;__PAGING_H__
