%ifndef __DEFS_COMMON_H__
%define __DEFS_COMMON_H__


;------------------------------------------------------------------------------
; Misc

%define NULL		0


;------------------------------------------------------------------------------
; Character definitions

%define CHAR_NUL	0x00
%define CHAR_TAB	0x09
%define CHAR_CR		0x0D
%define CHAR_LF		0x0A
%define CHAR_BS		0x08
%define CHAR_ESC	0x1B
%define CHAR_SQ		0x27
%define CHAR_DQ		0x22


;------------------------------------------------------------------------------
; Uncomment these to make regression test builds

;%define TEST_BITMAP


%endif ;__DEFS_COMMON_H__
