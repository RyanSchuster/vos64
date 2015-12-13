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


%ifndef __STRAPON_H__
%define __STRAPON_H__


%ifndef MOD_STRAPON


;------------------------------------------------------------------------------
; function: StraponStart
;
; brief: Entry point for the 32-bit to 64-bit stage
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
[extern StraponStart]


%endif ;MOD_STRAPON


%endif ;__STRAPON_H__
