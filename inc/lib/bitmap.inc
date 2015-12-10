;------------------------------------------------------------------------------
; module bitmap
;
; routines for managing bitmaps used for allocation
;------------------------------------------------------------------------------


%ifndef __BITMAP_H__
%define __BITMAP_H__


%ifndef MOD_BITMAP


;------------------------------------------------------------------------------
; function BitmapBitSet
;
; Sets a bit in a bitmap
;
; pass:
; rsi	-> bitmap
; rcx	= bitmap size in qwords
; rax	= bit index to set
;
; return:
; none
;
; notes:
; none
;------------------------------------------------------------------------------
[extern BitmapBitSet]


;------------------------------------------------------------------------------
; function BitmapBitClear
;
; Clears a bit in a bitmap
;
; pass:
; rsi	-> bitmap
; rcx	= bitmap size in qwords
; rax	= bit index to clear
;
; return:
; none
;
; notes:
; none
;------------------------------------------------------------------------------
[extern BitmapBitClear]


;------------------------------------------------------------------------------
; function BitmapBitFind
;
; Finds the first clear bit in a bitmap
;
; pass:
; rsi	-> bitmap
; rcx	= bitmap size in qwords
; rax	= bit index to start search
;
; return:
; cf	= set if no free bits, clear otherwise
; rax	= bit index of found bit
;
; notes:
; The start bit index is 64-bit aligned before starting, so under some
; conditions it could return a bit before the start bit.  The start bit index
; parameter is intended to be taken as a hint to speed up scans by starting
; past a large group of ones, so this behavior is not treated as a bug.
;------------------------------------------------------------------------------
[extern BitmapBitFind]


;------------------------------------------------------------------------------
; function BitmapRangeSet
;
; Sets a block of bits in a bitmap
;
; pass:
; rsi	-> bitmap
; rcx	= bitmap size in qwords
; rax	= bit index of first bit in range
; rbx	= length of range in bits
;
; return:
; none
;
; notes:
; none
;------------------------------------------------------------------------------
[extern BitmapRangeSet]


;------------------------------------------------------------------------------
; function BitmapRangeClear
;
; Clears a block of bits in a bitmap
;
; pass:
; rsi	-> bitmap
; rcx	= bitmap size in qwords
; rax	= bit index of first bit in range
; rbx	= length of range in bits
;
; return:
; none
;
; notes:
; none
;------------------------------------------------------------------------------
[extern BitmapRangeClear]


;------------------------------------------------------------------------------
; function BitmapRangeFind
;
; Finds the first block of clear bits in a bitmap
;
; pass:
; rsi	-> bitmap
; rcx	= bitmap size in qwords
; rax	= bit index to start search
;
; return:
; cf	= set if no clear bits, clear otherwise
; rax	= bit index of first bit in found range
; rbx	= length of found range in bits
;
; notes:
; The 64-bit alignment of the start bit index that happens in BitmapBitFind
; does NOT occur in this function, as it could lead to an actual bug when this
; function is used to scan for a block of at least some minimum size.
;------------------------------------------------------------------------------
[extern BitmapRangeFind]


;------------------------------------------------------------------------------
; function BitmapTest
;
; Runs regression tests of bitmap functions
;
; pass:
; none
;
; return:
; none
;
; notes:
; Only present when built with %define TEST_BITMAP 1 in defs.h
;------------------------------------------------------------------------------
[extern BitmapTest]


%endif ;MOD_BITMAP


%endif ;__BITMAP_H__
