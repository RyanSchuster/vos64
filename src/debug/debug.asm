%define MOD_DEBUG
; module: Debug


%include "debug/debug.inc"

%include "debug/console.inc"
%include "debug/serial.inc"

%include "defs.inc"



[section .text]
[bits 64]


[global DebugInit]
DebugInit:

%if DEBUG_CONSOLE
	call ConsoleInit
%endif

%if DEBUG_SERIAL
	call SerialInit
%endif

	ret


[global DebugPrint]
DebugPrint:
	push	rax
	push	rsi

	cld
.loop:
	lodsb
	test	al, al
	jz	.done
	call	DebugPutChar
	jmp	.loop
.done:

	pop	rsi
	pop	rax
	ret


[global DebugNewLine]
DebugNewLine:
	push	rax

	mov	al, CHAR_CR
	call	DebugPutChar
	mov	al, CHAR_LF
	call	DebugPutChar

	pop	rax
	ret


[global DebugClrScr]
DebugClrScr:

%if DEBUG_CONSOLE
	call	ConsoleClrScr
%endif

%if DEBUG_SERIAL
	call	SerialClrScr
%endif

	ret


[global DebugPutChar]
DebugPutChar:

%if DEBUG_CONSOLE
	call	ConsolePutChar
%endif

%if DEBUG_SERIAL
	call	SerialPutChar
%endif

	ret


[global DebugPutRaw]
DebugPutRaw:
	push	rax
	push	rdi

	; Check for printability
	mov	edi, '.'
	cmp	al, 0x20
	cmovb	eax, edi
	cmp	al, 0x7E
	cmova	eax, edi

	call	DebugPutChar

	pop	rdi
	pop	rax
	ret


[global DebugPrintHexB]
DebugPrintHexB:
	push	rax
	push	rbx
	push	rcx
	push	rdx

	mov	rcx, 0x00000002
	ror	rdx, 0x04
	; calls: DebugPrintHex
	jmp	DebugPrintHex


[global DebugPrintHexW]
DebugPrintHexW:
	push	rax
	push	rbx
	push	rcx
	push	rdx

	mov	rcx, 0x00000004
	ror	rdx, 0x0C
	; calls: DebugPrintHex
	jmp	DebugPrintHex


[global DebugPrintHexD]
DebugPrintHexD:
	push	rax
	push	rbx
	push	rcx
	push	rdx

	mov	rcx, 0x00000008
	ror	rdx, 0x1C
	; calls: DebugPrintHex
	jmp	DebugPrintHex


[global DebugPrintHexQ]
DebugPrintHexQ:
	push	rax
	push	rbx
	push	rcx
	push	rdx

	mov	rcx, 0x00000010
	rol	rdx, 0x04
	; calls: DebugPrintHex
	jmp	DebugPrintHex


;------------------------------------------------------------------------------
; function: DebugPrintHex
;
; brief: Internally called by DebugPrintHex[B|W|D|Q]
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
DebugPrintHex:
.loop:
	movzx	rbx, dl
	and	bl, 0x0F
	mov	al, [hexLookup + rbx]
	call	DebugPutChar
	rol	rdx, 0x04
	loop	.loop

	pop	rdx
	pop	rcx
	pop	rbx
	pop	rax
	ret


[global DebugPrintBinB]
DebugPrintBinB:
	; calls: DebugPrintBin
	ret


[global DebugPrintBinW]
DebugPrintBinW:
	; calls: DebugPrintBin
	ret


[global DebugPrintBinD]
DebugPrintBinD:
	; calls: DebugPrintBin
	ret


[global DebugPrintBinQ]
DebugPrintBinQ:
	; calls: DebugPrintBin
	ret


;------------------------------------------------------------------------------
; function: DebugPrintBin
;
; brief: Internally called by DebugPrintBin[B|W|D|Q]
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
DebugPrintBin:
	ret


[global DebugCoreDump]
DebugCoreDump:
	push	rax
	push	rcx
	push	rdx
	push	rdi
	push	r8

	and	rcx, rcx
	jz	.done
.rowLoop:
	; Print the address of the block
	mov	rdx, rdi
	call	DebugPrintHexQ
	mov	al, ':'
	call	DebugPutChar
	mov	al, ' '
	call	DebugPutChar

	; Print the block in hex bytes
	xor	r8, r8
.hexByteLoop:
	mov	dl, [rdi + r8]
	call	DebugPrintHexB
	mov	al, ' '
	call	DebugPutChar
	inc	r8
	cmp	r8b, 0x0F
	jbe	.hexByteLoop

	; Print the block in ascii
	xor	r8, r8
.asciiByteLoop:
	mov	al, [rdi + r8]
	call	DebugPutRaw
	inc	r8
	cmp	r8b, 0x0F
	jbe	.asciiByteLoop

	; Next row
	call	DebugNewLine
	add	rdi, 0x00000010
	loop	.rowLoop

.done:
	pop	r8
	pop	rdi
	pop	rdx
	pop	rcx
	pop	rax
	ret


[global DebugMotherfuck]
DebugMotherfuck:
	push	rsi

	mov	rsi, qword motherfuck
	call	DebugPrint

	pop	rsi
	ret


[global DebugRegComp]
DebugRegComp:
	push	rax
	push	rbx
	push	rcx
	push	rdx
	push	rsi

	xor	rbx, rbx
	xor	rcx, rcx

.loop:
	mov	rax, [r14 + rbx * 8]
	cmp	rax, [r15 + rbx * 8]
	je	.next
	or	cl, 0x01
	mov	rsi, [regCmpStrings + rbx * 8]
	call	DebugPrint
	mov	rdx, rax
	call	DebugPrintHexQ
	mov	al, CHAR_TAB
	call	DebugPutChar
	mov	rdx, [r15 + rbx * 8]
	call	DebugPrintHexQ
	call	DebugNewLine
.next:
	inc	rbx
	cmp	bl, 0x10
	jb	.loop

	clc
	test	cl, cl
	jz	.exit
	stc

.exit:
	pop	rsi
	pop	rdx
	pop	rcx
	pop	rbx
	pop	rax
	ret



[section .data]


hexLookup:
	db	"0123456789ABCDEF"

motherfuck:
	db	"I AM A MOTHERFUCKER", CHAR_CR, CHAR_LF, CHAR_NUL

regCmpStrings:
	dq	regCmpRax
	dq	regCmpRbx
	dq	regCmpRcx
	dq	regCmpRdx
	dq	regCmpRsi
	dq	regCmpRdi
	dq	regCmpRbp
	dq	regCmpRsp
	dq	regCmpR8
	dq	regCmpR9
	dq	regCmpR10
	dq	regCmpR11
	dq	regCmpR12
	dq	regCmpR13
	dq	regCmpR14
	dq	regCmpR15

regCmpRax:
	db	"rax", CHAR_TAB, CHAR_NUL
regCmpRbx:
	db	"rbx", CHAR_TAB, CHAR_NUL
regCmpRcx:
	db	"rcx", CHAR_TAB, CHAR_NUL
regCmpRdx:
	db	"rdx", CHAR_TAB, CHAR_NUL
regCmpRsi:
	db	"rsi", CHAR_TAB, CHAR_NUL
regCmpRdi:
	db	"rdi", CHAR_TAB, CHAR_NUL
regCmpRbp:
	db	"rbp", CHAR_TAB, CHAR_NUL
regCmpRsp:
	db	"rsp", CHAR_TAB, CHAR_NUL
regCmpR8:
	db	"r8 ", CHAR_TAB, CHAR_NUL
regCmpR9:
	db	"r9 ", CHAR_TAB, CHAR_NUL
regCmpR10:
	db	"r10", CHAR_TAB, CHAR_NUL
regCmpR11:
	db	"r11", CHAR_TAB, CHAR_NUL
regCmpR12:
	db	"r12", CHAR_TAB, CHAR_NUL
regCmpR13:
	db	"r13", CHAR_TAB, CHAR_NUL
regCmpR14:
	db	"r14", CHAR_TAB, CHAR_NUL
regCmpR15:
	db	"r15", CHAR_TAB, CHAR_NUL



[section .bss]
