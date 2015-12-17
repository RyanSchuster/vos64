%define MOD_CONSOLE
; module: Console


%include "debug/console.inc"

%include "defs/common.inc"


;------------------------------------------------------------------------------
; Video information

vidBase		equ	0x00000000000B8000

%define TEXT_ATTR	0x07

%define TEXT_COLUMNS	80
%define TEXT_ROWS	25
%define TEXT_CHARS	((TEXT_COLUMNS) * (TEXT_ROWS))
%define TEXT_QWORDS	((TEXT_CHARS) / 4)

%define BLANK_QWORD	0x0720072007200720



[section .text]
[bits 64]


[global ConsoleInit]
ConsoleInit:
	call	ConsoleClrScr
	ret


[global ConsolePutChar]
ConsolePutChar:
	push	rax
	push	rbx
	push	rdx
	push	rdi

	; Load the cursor offset FIXME clear upper dword of rdi?
	mov	edi, [cursor]

	; Check for special characters
	cmp	al, CHAR_CR
	je	.cr
	cmp	al, CHAR_LF
	je	.lf
	cmp	al, CHAR_TAB
	je	.tab

	; Print the character
	mov	ah, TEXT_ATTR
	mov	[vidBase + rdi * 2], ax
	inc	rdi
	jmp	.fixCursor

.cr:
	; Return cursor to beginning of row
	xor	rdx, rdx
	mov	rax, rdi
	mov	rbx, TEXT_COLUMNS
	div	rbx
	sub	rdi, rdx
	jmp	.fixCursor

.lf:
	; Move cursor to next line
	add	rdi, TEXT_COLUMNS
	jmp	.fixCursor

.tab:
	; 8-char align the cursor
	and	rdi, 0xFFFFFFF8
	add	rdi, 0x00000008

.fixCursor:
	cmp	rdi, TEXT_CHARS
	jb	.storeCursor
	sub	rdi, TEXT_COLUMNS
	call	ConsoleScroll
.storeCursor:
	mov	[cursor], edi
	call	ConsoleUpdateCursor

	pop	rdi
	pop	rdx
	pop	rbx
	pop	rax
	ret


[global ConsoleClrScr]
ConsoleClrScr:
	push	rax
	push	rcx
	push	rdi

	; Write spaces with the default attribute
	; The hardware cursor takes the attribute of the character it's over,
	; so it's important that all the characters have an attribute
	mov	rax, qword BLANK_QWORD
	mov	rcx, TEXT_QWORDS
	mov	rdi, vidBase
	rep	stosq

	; Reset the Cursor
	mov	[cursor], ecx	; ecx has zero from the rep loop
	call	ConsoleUpdateCursor

	pop	rdi
	pop	rcx
	pop	rax
	ret


;------------------------------------------------------------------------------
; function: ConsoleScroll
;
; brief: Scrolls the console output by one line
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
; Assumes the number of columns is a multiple of eight
; /
;------------------------------------------------------------------------------
ConsoleScroll:
	push	rax
	push	rcx
	push	rsi
	push	rdi

	; Copy data back by one line
	mov	rsi, vidBase + (TEXT_COLUMNS * 2)
	mov	rdi, vidBase
	mov	rcx, ((TEXT_ROWS - 1) * TEXT_COLUMNS) / 4
	rep	movsq

	; Clear the last line
	mov	rax, qword BLANK_QWORD
	mov	rcx, (TEXT_COLUMNS / 4)
	rep	stosq

	pop	rdi
	pop	rsi
	pop	rcx
	pop	rax
	ret


;------------------------------------------------------------------------------
; function: ConsoleUpdateCursor
;
; brief: Updates the blinky hardware cursor
;
; pass:
; di	= character offset of cursor
; /
;
; return:
; /
;
; sideeffects:
; /
;
; detail:
; TODO: %define magic numbers and constants later
; /
;------------------------------------------------------------------------------
ConsoleUpdateCursor:
	push	rax
	push	rdx

	; Low part of the cursor offset
	mov	al, 0x0F
	mov	dx, 0x03D4
	out	dx, al

	mov	ax, di
	mov	dx, 0x03D5
	out	dx, al

	; High part of the cursor offset
	mov	al, 0x0E
	mov	dx, 0x03D4
	out	dx, al

	mov	ax, di
	mov	al, ah
	mov	dx, 0x03D5
	out	dx, al

	pop	rdx
	pop	rax
	ret



[section .data]



[section .bss]


cursor:
	resd	1
