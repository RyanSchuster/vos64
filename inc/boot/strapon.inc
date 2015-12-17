;------------------------------------------------------------------------------
; module: Strapon
;
; brief: 32-bit to 64-bit bootstrap code
;
; detail:
; Because the folks who wrote the multiboot standard are WAAAY behind in the
; game.
;
; This sets up the state that multiboot compatible bootloaders _should_ set up
; for 64-bit images.
;
; FIXME: This makes the assumption that all the multiboot data structures are
; in the lower 2MB of ram.
; /
;------------------------------------------------------------------------------


%ifndef __STRAPON_INC__
%define __STRAPON_INC__


%ifndef MOD_STRAPON


;------------------------------------------------------------------------------
; function: StraponEntry
;
; brief: Entry point for the 32-bit to 64-bit stage
;
; pass:
; /
;
; return:
; Doesn't return
; /
;
; sideeffects:
; /
;
; detail:
; Sets up some temporary paging structures, enters long mode, and jumps to the
; entry point of the kernel proper (Entry).
; /
;------------------------------------------------------------------------------
[extern StraponEntry]


%endif ;MOD_STRAPON


%endif ;__STRAPON_INC__
