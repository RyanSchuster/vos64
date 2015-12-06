;------------------------------------------------------------------------------
; module debug
;
; useful routines for debugging
;
; can print out to the console or the serial port
;------------------------------------------------------------------------------


%ifndef __DEBUG_H__
%define __DEBUG_H__


%ifndef MOD_DEBUG


;------------------------------------------------------------------------------
; function DebugInit
;
; Sets up debug printing (console/serial) and sets up the breakpoint handler
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
; TODO: Set up breakpoint handler
;------------------------------------------------------------------------------
[extern DebugInit]


;------------------------------------------------------------------------------
; function DebugPrint
;
; Prints a null-terminated string, handling special chars
;
; pass:
; rsi	-> null-terminated string
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
[extern DebugPrint]


;------------------------------------------------------------------------------
; function DebugNewLine
;
; Puts the cursor on the next line
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
[extern DebugNewLine]


;------------------------------------------------------------------------------
; function DebugClrScr
;
; Clears the screen and resets the cursor (if using console debugging)
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
[extern DebugClrScr]


;------------------------------------------------------------------------------
; function DebugPutChar
;
; Prints a character, handling special characters
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
[extern DebugPutChar]


;------------------------------------------------------------------------------
; function DebugPutRaw
;
; Prints a character, not handling special characters
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
; Nonprintable characters are displayed as '.'
;------------------------------------------------------------------------------
[extern DebugPutRaw]


;------------------------------------------------------------------------------
; function DebugPrint[Hex|Bin][B|W|D|Q]
;
; Prints a byte/word/dword/qword in hex/binary
;
; pass:
; rax	= number to print
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
[extern DebugPrintHexB]
[extern DebugPrintHexW]
[extern DebugPrintHexD]
[extern DebugPrintHexQ]
[extern DebugPrintBinB]
[extern DebugPrintBinW]
[extern DebugPrintBinD]
[extern DebugPrintBinQ]


;------------------------------------------------------------------------------
; function DebugCoreDump
;
; Dumps a block of memory to the screen in hex/ascii
;
; pass:
; rdi	-> memory to dump
; rcx	= number of 16-byte blocks to dump
;
; return:
; none
;
; side effects:
; none
;
; notes:
; output looks like this:
; xxxxxxxxxxxxxxxx yy yy yy (. . .) yy zzz...z
;
; x - address
; y - hex data
; z - ascii data
;
; FIXME: will crash if address is bad
;------------------------------------------------------------------------------
[extern DebugCoreDump]


;------------------------------------------------------------------------------
; function DebugMotherfuck
;
; I AM A MOTHERFUCKER
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
; This is a valuable debugging routine.
;------------------------------------------------------------------------------
[extern DebugMotherfuck]


;------------------------------------------------------------------------------
; function DebugRegComp
;
; Compares two register snapshots
;
; pass:
; r14	-> pre snapshot
; r15	-> post snapshot
;
; return:
; cf	= set if mismatch, clear if match
;
; notes:
; For comparing registers before/after function calls for regression tests
;------------------------------------------------------------------------------
[extern DebugRegComp]


%endif ;MOD_DEBUG


;------------------------------------------------------------------------------
; for enabling/disabling debugging methods at build-time

%define DEBUG_CONSOLE	1
%define DEBUG_SERIAL	1


;------------------------------------------------------------------------------
; for comparing registers before/after function calls for regression tests

struc debug_snap_t
	.rax	resq 1
	.rbx	resq 1
	.rcx	resq 1
	.rdx	resq 1
	.rsi	resq 1
	.rdi	resq 1
	.rbp	resq 1
	.rsp	resq 1
	.r8	resq 1
	.r9	resq 1
	.r10	resq 1
	.r11	resq 1
	.r12	resq 1
	.r13	resq 1
	.r14	resq 1
	.r15	resq 1
endstruc

%macro REGSNAP 1
	push	r14
	push	r15
	mov	r15, %1
	mov	[r15 + debug_snap_t.rax], rax
	mov	[r15 + debug_snap_t.rbx], rbx
	mov	[r15 + debug_snap_t.rcx], rcx
	mov	[r15 + debug_snap_t.rdx], rdx
	mov	[r15 + debug_snap_t.rsi], rsi
	mov	[r15 + debug_snap_t.rdi], rdi
	mov	[r15 + debug_snap_t.rbp], rbp
	mov	[r15 + debug_snap_t.rsp], rsp	; TODO: fix address from push?
	mov	[r15 + debug_snap_t.r8], r8
	mov	[r15 + debug_snap_t.r9], r9
	mov	[r15 + debug_snap_t.r10], r10
	mov	[r15 + debug_snap_t.r11], r11
	mov	[r15 + debug_snap_t.r12], r12
	mov	[r15 + debug_snap_t.r13], r13
	mov	[r15 + debug_snap_t.r14], r14
	pop	r14
	mov	[r15 + debug_snap_t.r15], r14
	mov	r15, r14
	pop	r14
%endmacro


;------------------------------------------------------------------------------
; Quick and easy print wrappers

%macro PRINT 1
	pushf
	push	rsi
	mov	rsi, %%printStr
	call	DebugPrint
	jmp	%%printExit
%%printStr:
	db	%1, 0x0D, 0x0A, 0x00
%%printExit:
	pop	rsi
	popf
%endmacro

%macro PRINTQ 1
	pushf
	push	rdx
	mov	rdx, %1
	call	DebugPrintHexQ
	call	DebugNewLine
	pop	rdx
	popf
%endmacro

%macro PRINTD 1
	pushf
	push	rdx
	mov	edx, %1
	call	DebugPrintHexD
	call	DebugNewLine
	pop	rdx
	popf
%endmacro


%endif ;__DEBUG_H__
