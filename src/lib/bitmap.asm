%define MOD_BITMAP
; module: Bitmap


%include "lib/bitmap.inc"

%include "defs/common.inc"

%ifdef TEST_BITMAP
%include "debug/debug.inc"
%endif ; TEST_BITMAP



[section .text]
[bits 64]


[global BitmapBitSet]
BitmapBitSet:
	push	rax
	push	rcx
	push	rdx

	; TODO: pointer check
	; TODO: bounds check

	; Get the offset of the bit into its containing qword
	mov	cl, al		; only take the low byte
	and	cl, 0x3F	; only take the low 6 bits of that byte

	; Get the index of the bit's containing qword
	shr	rax, 0x06

	; Generate a mask to set the bit
	xor	rdx, rdx	; put 0...01 into rdx (lowest bit set)
	inc	rdx
	shl	rdx, cl		; shift the one into position

	; Set the bit
	; NOTE: would byte-aligned rax be better?
	or	[rsi + rax * 8], rdx

	pop	rdx
	pop	rcx
	pop	rax
	ret


[global BitmapBitClear]
BitmapBitClear:
	push	rax
	push	rcx
	push	rdx

	; TODO: pointer check
	; TODO: bounds check

	; Get the offset of the bit into its containing qword
	mov	cl, al		; only take the low byte
	and	cl, 0x3F	; only take the low 6 bits of that byte

	; Get the index of the bit's containing qword
	shr	rax, 0x06

	; Generate a mask to clear the bit
	xor	rdx, rdx	; put F...FE into rdx (lowest bit clear)
	dec	rdx
	dec	rdx
	rol	rdx, cl		; shift the zero into position

	; Clear the bit
	; NOTE: would byte-aligned rax be better?
	and	[rsi + rax * 8], rdx

	pop	rdx
	pop	rcx
	pop	rax
	ret


[global BitmapBitFind]
BitmapBitFind:
	push	rcx
	push	rdi

	; TODO: pointer check

	; Point the bitmap pointer at the starting bit's containing qword
	mov	rdi, rsi	; copy pointer to our scan register
	and	al, 0xC0	; 64-bit align the start bit index
	shr	rax, 0x03	; convert bit-index to byte-index
	add	rdi, rax	; add to pointer to point to start qword

	; Reduce bitmap size counter to account for skipped over qwords
	shr	rax, 0x03	; convert byte-index to qword index
	sub	rcx, rax	; subtract from bitmap size

	; TODO: check the first qword by hand, masking off bits earlier than
	; the starting bit?

	; Loop until a non-full qword is found
	; NOTE: would loop be better than scasq?
	xor	rax, rax	; put all-Fs in rax to compare against
	dec	rax
	repe	scasq		; scan until we point at a non-Fs qword
	stc			; set the carry flag in case of failure
	je	.fail		; if we ran out of bitmap then we failed
	sub	rdi, 0x08	; scasq puts us a qword too far, drop back one

	; Get the bit offset of the first zero bit within the qword
	mov	rax, [rdi]	; load the qword containing our bit
	not	rax		; invert so we can scan for the zero as a one
	bsf	rax, rax	; find the first one bit

	; Get the qword index of the containing qword
	sub	rdi, rsi	; subtract the bitmap base from the pointer
	shl	rdi, 0x03	; convert byte-index to bit-index
	add	rax, rdi	; add the qword index to the bit offset

	clc			; success, clear the carry flag
.fail:
	pop	rdi
	pop	rcx
	ret


[global BitmapRangeSet]
BitmapRangeSet:
	push	rax
	push	rbx
	push	rcx
	push	rdx
	push	r8

	; Turn length into end bit index
	add	rbx, rax

	; TODO: bounds check

	; Get start and end bit offsets
	mov	cl, al		; only take the low byte
	and	cl, 0x3F	; only take the low 6 bits of that byte
	mov	ch, bl		; same, but in the other 8-bit c register
	and	ch, 0x3F

	; Get start and end qword indexes
	shr	rax, 0x06
	shr	rbx, 0x06

	; Create mask for the first qword
	xor	rdx, rdx	; start with all Fs
	dec	rdx
	shl	rdx, cl		; put zeros up to the start bit

	; Create mask for the final qword
	mov	cl, ch		; use the end bit's offset
	xor	r8, r8		; start with all Fs
	dec	r8
	shl	r8, cl		; put zeros up to the end bit
	not	r8		; invert, now has ones up to the end bit

	; Check for the case where the block is contained in a single qword
	cmp	rax, rbx
	jne	.maskFirst
	and	r8, rdx		; combine masks, keeping the zeros from each
	jmp	.maskFinal

	; Write the first qword of ones
.maskFirst:
	or	[rsi + rax * 8], rdx

	; Loop and write the middle qwords of ones
	; NOTE: find a way to use rep stosq here?
	xor	rdx, rdx	; load all Fs to write later
	dec	rdx
.loop:
	inc	rax		; next qword
	cmp	rax, rbx	; break if this is the last qword
	je	.maskFinal
	mov	[rsi + rax * 8], rdx	; store the ones
	jmp	.loop

	; Write the last qword of ones
.maskFinal:
	or	[rsi + rbx * 8], r8

	pop	r8
	pop	rdx
	pop	rcx
	pop	rbx
	pop	rax
	ret


[global BitmapRangeClear]
BitmapRangeClear:
	push	rax
	push	rbx
	push	rcx
	push	rdx
	push	r8

	; Turn length into end bit index
	add	rbx, rax

	; TODO: bounds check

	; Get start and end bit offsets
	mov	cl, al		; only take the low byte
	and	cl, 0x3F	; only take the low 6 bits of that byte
	mov	ch, bl		; same, but in the other 8-bit c register
	and	ch, 0x3F

	; Get start and end qword indexes
	shr	rax, 0x06
	shr	rbx, 0x06

	; Create mask for the first qword
	xor	rdx, rdx	; start with all Fs
	dec	rdx
	shl	rdx, cl		; put zeros up to the start bit
	not	rdx		; invert, now has ones up to the start bit

	; Create mask for the final qword
	mov	cl, ch		; use the end bit's offset
	xor	r8, r8		; start with all Fs
	dec	r8
	shl	r8, cl		; put zeros up to the end bit

	; Check for the case where the block is contained in a single qword
	cmp	rax, rbx
	jne	.maskFirst
	or	r8, rdx		; combine masks, keeping ones from each
	jmp	.maskFinal

	; Write the first qword of zeros
.maskFirst:
	and	[rsi + rax * 8], rdx

	; Loop and write the middle qwords of zeros
	xor	rdx, rdx	; load all 0s to write later
.loop:
	inc	rax		; next qword
	cmp	rax, rbx	; break if this is the last qword
	je	.maskFinal
	mov	[rsi + rax * 8], rdx	; store the zeros
	jmp	.loop

	; Write the last qword of zeros
.maskFinal:
	and	[rsi + rbx * 8], r8

	pop	r8
	pop	rdx
	pop	rcx
	pop	rbx
	pop	rax
	ret


[global BitmapRangeFind]
BitmapRangeFind:
	push	rcx
	push	rdx
	push	rdi
	push	rbp		; NOTE: let rbp get clobbered? no one uses it

	; Check the first qword by hand to skip over stuff before the start bit

	mov	rdx, rcx	; we need cl, save bitmap size somewhere else

	; Get the bit offset and qword index of the start bit
	mov	cl, al		; only take the low byte
	and	cl, 0x3F	; only take the low 6 bits of that byte
	shr	rax, 0x06	; convert bit-index to qword-index

	; Mask off the bits before the start bit to be sure they are skipped
	xor	rbx, rbx	; start with all Fs
	dec	rbx
	shl	rbx, cl		; shift zeros up to the start bit
	not	rbx		; invert, now has ones up to the start bit
	mov	rcx, rdx	; done with cl, can use rcx for count again
	mov	rdx, [rsi + rax * 8]	; load the first qword to scan
	or	rdx, rbx	; put ones before start bit so we skip them

	; Scan for the first non-all-Fs qword
	; We've already loaded the first one and masked bits to skip
	sub	rcx, rax	; subtract the starting qword index from size
.startLoop:
	not	rdx		; invert qword, now we're looking for a one
	test	rdx, rdx	; are there any ones in the qword?
	jnz	.foundStart	; yes, we found our start qword
	inc	rax		; no, next qword
	mov	rdx, [rsi + rax * 8]	; load next qword
	loop	.startLoop	; loop while we have more bitmap to scan

	; If we reached here, we ran out of bitmap - failure
	stc			; set carry to indicate failure
	jmp	.exit

	; Get the index of the first zero found
.foundStart:
	mov	rbx, rax	; put qword index somewhere else for later
	shl	rax, 0x06	; convert qword-index into bit-index
	bsf	rdi, rdx	; find the offset of the first bit
	add	rax, rdi	; add bit offset to get full index

	; Find the first one after the first zero to get the end point

	; Mask off bits before the start bit, just in case
	xchg	rcx, rdi	; bitmap size saved in rdi, bit offet in cl
	xor	rbp, rbp	; start with all Fs
	dec	rbp
	shl	rbp, cl		; shift zeros up to the start bit
	mov	rcx, rdi	; done with cl, can use rcx for count again
	not	rdx		; invert back to look for ones instead of zeros
	and	rdx, rbp	; put zeros before the start bit to skip them

	; Scan for the first non-all-0s qword
	; We've already loaded the first one and masked bits to skip
	; rbx <- qword index
.endLoop:
	test	rdx, rdx	; are there any ones in the qword?
	jnz	.foundEnd	; yes, we found the end qword
	inc	rbx		; no, next qword
	mov	rdx, [rsi + rbx * 8]	; load next qword
	loop	.endLoop	; loop while we have more bitmap to scan

	; If we reached here we ran out of bitmap - set first one as one-past
	xor	cl, cl		; bit index is 64 - first bit after bitmap end
	jmp	.haveBitOffset	; skip over the bitscan

	; If we reached here we found a bitmap qword with a one in it
.foundEnd:
	bsf	rcx, rdx	; find the offset of the first bit

	; Convert qword index and bit offset into range length
.haveBitOffset:
	shl	rbx, 0x06	; convert qword-index into bit index
	add	rbx, rcx	; add bit offset to get full index
	sub	rbx, rax	; subtract first bit index to get length

	clc			; clear carry to indicate success
.exit:
	pop	rbp
	pop	rdi
	pop	rdx
	pop	rcx
	ret


%ifdef TEST_BITMAP

;-------------------------------------------------------------------------------
; function: BitmapPrint
;
; brief: Prints bitmap contents for debugging
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
;-------------------------------------------------------------------------------
BitmapPrint:
	PRINT	"Bitmap contents:"
	xor	rax, rax
.loop:
	mov	rdx, [rsi + rax * 8]
	call	DebugPrintHexQ
	call	DebugNewLine
	inc	rax
	loop	.loop

	ret


[global BitmapTest]
BitmapTest:
	mov	r14, preSnap
	mov	r15, postSnap

	;-----------------------------------------------------------------------
	; BitmapBitSet

	; ----- Set first bit of first qword
	PRINT	"BitSet: Set first bit of first qword"

	mov	rsi, testmap1
	mov	rcx, 0x00000003
	xor	rax, rax

	REGSNAP	preSnap
	call	BitmapBitSet
	REGSNAP	postSnap

	call	DebugRegComp
	jc	.test1Fail

	mov	r8, [testmap1]
	cmp	r8, 0x00000001
	jne	.test1Fail

	PRINT 	"PASSED"
	jmp	.test1Done
.test1Fail:
	jmp	.fail
.test1Done:


	; ----- Set last bit of last qword
	PRINT	"BitSet: Set last bit of last qword"

	mov	rax, 64 * 3 - 1

	REGSNAP	preSnap
	call	BitmapBitSet
	REGSNAP	postSnap

	call	DebugRegComp
	jc	.test2Fail

	mov	r8, [testmap1 + 8 * 2]
	mov	r9, 0x80000000
	shl	r9, 0x20
	cmp	r8, r9
	jne	.test2Fail

	PRINT	"PASSED"
	jmp	.test2Done
.test2Fail:
	jmp	.fail
.test2Done:


	; ----- Set middle bit of middle qword
	PRINT	"BitSet: Set middle bit of middle qword"

	mov	rax, 64 + 31

	REGSNAP	preSnap
	call	BitmapBitSet
	REGSNAP	postSnap

	call	DebugRegComp
	jc	.test3Fail

	mov	r8, [testmap1 + 8]
	mov	r9, 0x80000000
	cmp	r8, r9
	jne	.test3Fail

	PRINT	"PASSED"
	jmp	.test3Done
.test3Fail:
	jmp	.fail
.test3Done:


	; TODO: Try to set bit outside bitmap bounds


	;-----------------------------------------------------------------------
	; BitmapBitClear

	; ----- Clear first bit of first qword
	PRINT	"BitClear: Clear first bit of first qword"

	mov	rsi, testmap2
	mov	rcx, 0x00000003
	mov	rax, 0x00000000

	REGSNAP	preSnap
	call	BitmapBitClear
	REGSNAP	postSnap

	call	DebugRegComp
	jc	.test4Fail

	mov	r8, [testmap2]
	cmp	r8d, 0xFFFFFFFE
	jne	.test4Fail

	PRINT	"PASSED"
	jmp	.test4Done
.test4Fail:
	jmp	.fail
.test4Done:


	; ----- Clear last bit of last qword
	PRINT	"BitClear: Clear last bit of last qword"

	mov	rsi, testmap2
	mov	rcx, 0x00000003
	mov	rax, 64 * 3 - 1

	REGSNAP	preSnap
	call	BitmapBitClear
	REGSNAP	postSnap

	call	DebugRegComp
	jc	.test5Fail

	mov	r8, [testmap2 + 2 * 8]
	mov	r9, 0xFFFFFFFFFFFFFFFE
	ror	r9, 1
	cmp	r8, r9
	jne	.test5Fail

	PRINT	"PASSED"
	jmp	.test5Done
.test5Fail:
	jmp	.fail
.test5Done:

	; ----- Clear middle bit of middle qword
	; test 6: skipping to save time

	; TODO: test out of bounds


	;-----------------------------------------------------------------------
	; BitmapBitFind

	; find in first qword with later bits free
	PRINT	"BitFind: Find in first qword with later bits free"

	mov	rsi, testmap3
	mov	rcx, 0x00000003
	mov	rax, 0

	REGSNAP	preSnap
	call	BitmapBitFind
	REGSNAP	postSnap

	jc	.test7Fail

	mov	rax, 4
	mov	[r14 + debug_snap_t.rax], rax
	call	DebugRegComp
	jc	.test7Fail

	PRINT	"PASSED"
	jmp	.test7Done
.test7Fail:
	jmp	.fail
.test7Done:


	; skip over qword and find last bit of last qword
	PRINT	"BitFind: Skip over qword and find last bit of last qword"

	mov	rsi, testmap3
	mov	rcx, 0x00000003
	mov	rax, 64

	REGSNAP	preSnap
	call	BitmapBitFind
	REGSNAP	postSnap

	jc	.test8Fail

	mov	rax, 64 * 3 - 1
	mov	[r14 + debug_snap_t.rax], rax
	call	DebugRegComp
	jc	.test8Fail

	PRINT	"PASSED"
	jmp	.test8Done
.test8Fail:
	jmp	.fail
.test8Done:


	; no available bits with bits clear after final qword
	PRINT	"BitFind: No available bits with bits clear after final qword"

	mov	rsi, testmap4
	mov	rcx, 0x00000003
	mov	rax, 0

	REGSNAP	preSnap
	call	BitmapBitFind
	REGSNAP	postSnap

	jnc	.test9Fail

	mov	rax, [r15 + debug_snap_t.rax]
	mov	[r14 + debug_snap_t.rax], rax
	call	DebugRegComp
	jc	.test9Fail

	PRINT	"PASSED"
	jmp	.test9Done
.test9Fail:
	jmp	.fail
.test9Done:


	;-----------------------------------------------------------------------
	; BitmapRangeSet

	; start at beginning of first qword
	PRINT	"RangeSet: Start at beginning of first qword"

	mov	rsi, testmap5
	mov	rcx, 5
	mov	rax, 0
	mov	rbx, 8

	REGSNAP	preSnap
	call	BitmapRangeSet
	REGSNAP	postSnap

	call	DebugRegComp
	jc	.test10Fail

	mov	r8, [testmap5]
	cmp	r8, 0x000000FF
	jne	.test10Fail

	PRINT	"PASSED"
	jmp	.test10Done
.test10Fail:
	jmp	.fail
.test10Done:


	; stop at end of last qword
	PRINT	"RangeSet: Stop at end of last qword"

	mov	rsi, testmap5
	mov	rcx, 5
	mov	rax, 64 * 5 - 8
	mov	rbx, 8

	REGSNAP	preSnap
	call	BitmapRangeSet
	REGSNAP	postSnap

	call	DebugRegComp
	jc	.test11Fail

	mov	r8, [testmap5 + 8 * 4]
	shr	r8, 32
	cmp	r8d, 0xFF000000
	jne	.test11Fail

	mov	r8, [testmap5 + 8 * 5]
	cmp	r8, 0
	jne	.test11Fail

	PRINT	"PASSED"
	jmp	.test11Done
.test11Fail:
	mov	rcx, 6
	jmp	.fail
.test11Done:


	; span two qwords
	PRINT	"RangeSet: Span two qwords"

	mov	rsi, testmap5
	mov	rcx, 5
	mov	rax, 64 + 32 + 16
	mov	rbx, 32

	REGSNAP	preSnap
	call	BitmapRangeSet
	REGSNAP	postSnap

	call	DebugRegComp
	jc	.test12Fail

	mov	r8, [testmap5 + 8]
	shr	r8, 32
	cmp	r8d, 0xFFFF0000
	jne	.test12Fail

	mov	r8, [testmap5 + 8 * 2]
	cmp	r8, 0x0000FFFF
	jne	.test12Fail

	PRINT	"PASSED"
	jmp	.test12Done
.test12Fail:
	mov	rcx, 6
	jmp	.fail
.test12Done:


	; span more than two qwords
	PRINT	"RangeSet: Span more than two qwords"

	mov	rsi, testmap5
	mov	rcx, 5
	mov	rax, 64 * 2 + 32 + 16
	mov	rbx, 64 + 32

	REGSNAP	preSnap
	call	BitmapRangeSet
	REGSNAP	postSnap

	call	DebugRegComp
	jc	.test13Fail

	mov	r8, [testmap5 + 8 * 2]
	shr	r8, 32
	cmp	r8d, 0xFFFF0000
	jne	.test13Fail

	mov	r8, [testmap5 + 8 * 3]
	xor	r9, r9
	not	r9
	cmp	r8, r9
	jne	.test13Fail

	mov	r8, [testmap5 + 8 * 4]
	cmp	r8d, 0x0000FFFF
	jne	.test13Fail

	PRINT	"PASSED"
	jmp	.test13Done
.test13Fail:
	mov	rcx, 6
	jmp	.fail
.test13Done:


	;-----------------------------------------------------------------------
	; BitmapRangeClear

	; start at beginning of qword
	PRINT	"RangeClear: Start at beginning of first qword"

	mov	rsi, testmap6
	mov	rcx, 5
	mov	rax, 0
	mov	rbx, 8

	REGSNAP	preSnap
	call	BitmapRangeClear
	REGSNAP	postSnap

	call	DebugRegComp
	jc	.test14Fail

	mov	r8, [testmap6]
	cmp	r8d, 0xFFFFFF00
	jne	.test14Fail

	PRINT	"PASSED"
	jmp	.test14Done
.test14Fail:
	mov	rcx, 6
	jmp	.fail
.test14Done:

	; end at end of qword
	; skip to save time

	; span two qwords
	PRINT	"RangeClear: Span two qwords"

	mov	rsi, testmap6
	mov	rcx, 5
	mov	rax, 64 + 32 + 16
	mov	rbx, 32

	REGSNAP	preSnap
	call	BitmapRangeClear
	REGSNAP	postSnap

	call	DebugRegComp
	jc	.test16Fail

	mov	r8, [testmap6 + 8]
	shr	r8, 32
	cmp	r8d, 0x0000FFFF
	jne	.test16Fail

	mov	r8, [testmap6 + 8 * 2]
	cmp	r8d, 0xFFFF0000
	jne	.test16Fail

	PRINT	"PASSED"
	jmp	.test16Done
.test16Fail:
	mov	rcx, 6
	jmp	.fail
.test16Done:

	; span more than two qwords
	PRINT	"RangeClear: Span more than two qwords"

	mov	rsi, testmap6
	mov	rcx, 5
	mov	rax, 64 * 2 + 32 + 16
	mov	rbx, 64 + 32

	REGSNAP	preSnap
	call	BitmapRangeClear
	REGSNAP	postSnap

	mov	r8, [testmap6 + 8 * 2]
	shr	r8, 32
	cmp	r8d, 0x0000FFFF
	jne	.test17Fail

	mov	r8, [testmap6 + 8 * 3]
	test	r8, r8
	jnz	.test17Fail

	mov	r8, [testmap6 + 8 * 4]
	cmp	r8d, 0xFFFF0000
	jne	.test17Fail

	call	DebugRegComp
	jc	.test17Fail

	PRINT	"PASSED"
	jmp	.test17Done
.test17Fail:
	mov	rcx, 6
	jmp	.fail
.test17Done:


	;-----------------------------------------------------------------------
	; BitmapRangeFind

	; find at beginning of first qword
	PRINT	"RangeFind: Find at beginning of first qword"

	mov	rsi, testmap7
	mov	rcx, 8
	mov	rax, 0

	REGSNAP	preSnap
	call	BitmapRangeFind
	REGSNAP	postSnap

	jc	.test18Fail

	mov	r8, 0
	mov	[r14 + debug_snap_t.rax], r8
	mov	r8, 8
	mov	[r14 + debug_snap_t.rbx], r8

	call	DebugRegComp
	jc	.test18Fail

	PRINT	"PASSED"
	jmp	.test18Done
.test18Fail:
	jmp	.fail
.test18Done:


	; span two qwords
	PRINT	"RangeFind: Span two qwords"

	mov	rsi, testmap7
	mov	rcx, 8
	mov	rax, 64

	REGSNAP	preSnap
	call	BitmapRangeFind
	REGSNAP	postSnap

	jc	.test20Fail

	mov	r8, 64 + 32 + 16
	mov	[r14 + debug_snap_t.rax], r8
	mov	r8, 32
	mov	[r14 + debug_snap_t.rbx], r8

	call	DebugRegComp
	jc	.test20Fail

	PRINT	"PASSED"
	jmp	.test20Done
.test20Fail:
	jmp	.fail
.test20Done:


	; span more than two qwords
	PRINT	"RangeFind: Span more than two qwords"

	mov	rsi, testmap7
	mov	rcx, 8
	mov	rax, 64 * 3

	REGSNAP	preSnap
	call	BitmapRangeFind
	REGSNAP	postSnap

	jc	.test21Fail

	mov	r8, 64 * 3 + 32 + 16
	mov	[r14 + debug_snap_t.rax], r8
	mov	r8, 64 + 32
	mov	[r14 + debug_snap_t.rbx], r8

	call	DebugRegComp
	jc	.test21Fail

	PRINT	"PASSED"
	jmp	.test21Done
.test21Fail:
	jmp	.fail
.test21Done:


	; skip over a free range in the same qword
	PRINT	"RangeFind: Skip over a free range in the same qword"

	mov	rsi, testmap7
	mov	rcx, 8
	mov	rax, 12

	REGSNAP	preSnap
	call	BitmapRangeFind
	REGSNAP	postSnap

	jc	.test22Fail

	mov	r8, 16
	mov	[r14 + debug_snap_t.rax], r8
	mov	r8, 8
	mov	[r14 + debug_snap_t.rbx], r8

	call	DebugRegComp
	jc	.test22Fail

	PRINT	"PASSED"
	jmp	.test22Done
.test22Fail:
	jmp	.fail
.test22Done:


	; find at end of last qword with more bits clear after final qword
	PRINT	"RangeFind: Find at end of last qword with more bits clear"

	mov	rsi, testmap7
	mov	rcx, 8
	mov	rax, 64 * 5 + 32

	REGSNAP	preSnap
	call	BitmapRangeFind
	REGSNAP	postSnap

	jc	.test19Fail

	mov	r8, 64 * 5 + 32 + 16
	mov	[r14 + debug_snap_t.rax], r8
	mov	r8, 64 * 2 + 16
	mov	[r14 + debug_snap_t.rbx], r8

	call	DebugRegComp
	jc	.test19Fail

	PRINT	"PASSED"
	jmp	.test19Done
.test19Fail:
	jmp	.fail
.test19Done:


	; no free blocks with bits clear after final qword
	PRINT	"RangeFind: No available bits with bits clear after final qword"

	mov	rsi, testmap8
	mov	rcx, 3
	mov	rax, 0

	REGSNAP	preSnap
	call	BitmapRangeFind
	REGSNAP	postSnap

	jnc	.test23Fail

	mov	r8, [r15 + debug_snap_t.rax]
	mov	[r14 + debug_snap_t.rax], r8
	mov	r8, [r15 + debug_snap_t.rbx]
	mov	[r14 + debug_snap_t.rbx], r8

	call	DebugRegComp
	jc	.test23Fail

	PRINT	"PASSED"
	jmp	.test23Done
.test23Fail:
	jmp	.fail
.test23Done:


	; ----- DONE - All tests passed
	PRINT	"All tests passed."
	ret

.fail:
	PRINT	"FAILED"
	call	BitmapPrint
	ret

%endif ; TEST_BITMAP



[section .data]


%ifdef TEST_BITMAP

;-------------------------------------------------------------------------------
; Test bitmaps

testmap1:
	dq	0x0000000000000000
	dq	0x0000000000000000
	dq	0x0000000000000000
testmap2:
	dq	0xFFFFFFFFFFFFFFFF
	dq	0xFFFFFFFFFFFFFFFF
	dq	0xFFFFFFFFFFFFFFFF
testmap3:
	dq	0xFFFFFFFEFFFFFFEF
	dq	0xFFFFFFFFFFFFFFFF
	dq	0x7FFFFFFFFFFFFFFF
testmap4:
	dq	0xFFFFFFFFFFFFFFFF
	dq	0xFFFFFFFFFFFFFFFF
	dq	0xFFFFFFFFFFFFFFFF
	dq	0x0000000000000000	; outside bitmap
testmap5:
	dq	0x0000000000000000
	dq	0x0000000000000000
	dq	0x0000000000000000
	dq	0x0000000000000000
	dq	0x0000000000000000
	dq	0x0000000000000000	; outside bitmap
testmap6:
	dq	0xFFFFFFFFFFFFFFFF
	dq	0xFFFFFFFFFFFFFFFF
	dq	0xFFFFFFFFFFFFFFFF
	dq	0xFFFFFFFFFFFFFFFF
	dq	0xFFFFFFFFFFFFFFFF
testmap7:
	dq	0xFF00FF00FF00FF00
	dq	0x0000FFFFFFFFFFFF
	dq	0xFFFFFFFFFFFF0000
	dq	0x0000FFFFFFFFFFFF
	dq	0x0000000000000000
	dq	0x0000FFFFFFFF0000
	dq	0x0000000000000000
	dq	0x0000000000000000
	dq	0x0000000000000000	; outside bitmap
	dq	0xFFFFFFFF00000000	; outside bitmap
testmap8:
	dq	0xFFFFFFFFFFFFFFFF
	dq	0xFFFFFFFFFFFFFFFF
	dq	0xFFFFFFFFFFFFFFFF
	dq	0x0000000000000000	; outside bitmap


;-------------------------------------------------------------------------------
; Output strings

bitSetFirstQFirstB:
	db	"Set first bit of first qword", CHAR_CR, CHAR_LF, CHAR_NUL
bitSetLastQLastB:
	db	"Set last bit of last qword", CHAR_CR, CHAR_LF, CHAR_NUL
bitSetMidQMidB:
	db	"Set middle bit of middle qword", CHAR_CR, CHAR_LF, CHAR_NUL

testFail:
	db	"FAILED", CHAR_CR, CHAR_LF, CHAR_NUL
testPass:
	db	"PASSED", CHAR_CR, CHAR_LF, CHAR_NUL
testAllPass:
	db	"Bitmap test suite passed", CHAR_CR, CHAR_LF, CHAR_NUL

bitmapStr:
	db	"Bitmap contents:", CHAR_CR, CHAR_LF, CHAR_NUL


%endif ; TEST_BITMAP



[section .bss]


%ifdef TEST_BITMAP

preSnap:
	resb	debug_snap_t_size

postSnap:
	resb	debug_snap_t_size

%endif ; TEST_BITMAP
