;------------------------------------------------------------------------------
; module serial
;
; Serial port output for out-of-band debugging
;------------------------------------------------------------------------------


%ifndef __SERIAL_H__
%define __SERIAL_H__


%ifndef MOD_SERIAL


;------------------------------------------------------------------------------
; function SerialInit
;
; Sets up the serial port for output
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
; TODO: Document port setup (baud/parity/etc.)
;------------------------------------------------------------------------------
[extern SerialInit]


;------------------------------------------------------------------------------
; function SerialPutChar
;
; Writes a character to the serial port, handling special characters
;
; pass:
; al	= character to write
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
[extern SerialPutChar]


;------------------------------------------------------------------------------
; function SerialClrScr
;
; Records that a screen clear happened
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
; notes
; none
;------------------------------------------------------------------------------
[extern SerialClrScr]


%endif ;MOD_SERIAL


%endif ;__SERIAL_H__
