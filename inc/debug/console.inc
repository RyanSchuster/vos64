;------------------------------------------------------------------------------
; module console
;
; console output for out-of-band debugging
;------------------------------------------------------------------------------


%ifndef __CONSOLE_H__
%define __CONSOLE_H__


%ifndef MOD_CONSOLE


;------------------------------------------------------------------------------
; function ConsoleInit
;
; Sets up the console output
;
; pass:
; none
;
; return:
; none
;
; side effects:
; none
;
; notes:
; none
;------------------------------------------------------------------------------
[extern ConsoleInit]


;------------------------------------------------------------------------------
; function ConsolePutChar
;
; Writes a character, handling special characters
;
; pass:
; al	= character to print
;
; return:
; none
;
; side effects:
; none
;
; notes:
; Handles CR, LF, and TAB
;------------------------------------------------------------------------------
[extern ConsolePutChar]


;------------------------------------------------------------------------------
; function ConsoleClrScr
;
; Clears console output and resets the cursor
;
; pass:
; none
;
; return:
; none
;
; side effects:
; none
;
; notes:
; none
;------------------------------------------------------------------------------
[extern ConsoleClrScr]


%endif ;MOD_CONSOLE


%endif ;__CONSOLE_H__
