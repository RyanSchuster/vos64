;------------------------------------------------------------------------------
; module: Console
;
; brief: Console output for out-of-band debugging
;
; detail:
; This is not meant as a device driver, only as one possible output for the
; Debug module.
; /
;------------------------------------------------------------------------------


%ifndef __CONSOLE_H__
%define __CONSOLE_H__


%ifndef MOD_CONSOLE


;------------------------------------------------------------------------------
; function: ConsoleInit
;
; brief: Sets up the console output
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
[extern ConsoleInit]


;------------------------------------------------------------------------------
; function: ConsolePutChar
;
; brief: Writes a character, handling special characters
;
; pass:
; al	= character to print
; /
;
; return:
; /
;
; side effects:
; /
;
; detail:
; Handles CR, LF, and TAB
; /
;------------------------------------------------------------------------------
[extern ConsolePutChar]


;------------------------------------------------------------------------------
; function: ConsoleClrScr
;
; brief: Clears console output and resets the cursor
;
; pass:
; /
;
; return:
; /
;
; side effects:
; /
;
; detail:
; /
;------------------------------------------------------------------------------
[extern ConsoleClrScr]


%endif ;MOD_CONSOLE


%endif ;__CONSOLE_H__
