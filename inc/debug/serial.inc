;------------------------------------------------------------------------------
; module: Serial
;
; brief: Serial port output for out-of-band debugging
;
; detail:
; /
;------------------------------------------------------------------------------


%ifndef __SERIAL_INC__
%define __SERIAL_INC__


%ifndef MOD_SERIAL


;------------------------------------------------------------------------------
; function: SerialInit
;
; brief: Sets up the serial port for output
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
; TODO: Document port setup (baud/parity/etc.)
; /
;------------------------------------------------------------------------------
[extern SerialInit]


;------------------------------------------------------------------------------
; function: SerialPutChar
;
; brief: Writes a character to the serial port, handling special characters
;
; pass:
; al	= character to write
; /
;
; return:
; /
;
; sideeffects:
; /
;
; detail:
; Handles CR, LF, and TAB
; /
;------------------------------------------------------------------------------
[extern SerialPutChar]


;------------------------------------------------------------------------------
; function: SerialClrScr
;
; brief: Records that a screen clear happened
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
[extern SerialClrScr]


%endif ;MOD_SERIAL


%endif ;__SERIAL_INC__
