%define MOD_ENTRY


%include "defs.inc"
%include "layout.inc"
%include "debug/debug.inc"

%include "hal/pmem.inc"

%ifdef TEST_BITMAP
%include "lib/bitmap.inc"
%endif ;TEST_BITMAP



[section .text]
[bits 64]

[global Entry]
Entry:
	mov	rsp, stack

	call	DebugInit

%ifdef TEST_BITMAP
	;call	BitmapTest
	cli
	hlt
%endif

	;call	PMemInit
	;loadAddrBegin
	;loadAddrEnd
	;loadSize

	PRINTQ	kernSize

	cli
	hlt



[section .data]


message:
	db	"There is no chin under Mr. Vos's beard.  Only another beard.", CHAR_CR, CHAR_LF, CHAR_NUL



[section .bss]


testSnap1:
	resb	debug_snap_t_size

testSnap2:
	resb	debug_snap_t_size


	resb	0x1000
stack:

test_bss:
	resb	0x100000
