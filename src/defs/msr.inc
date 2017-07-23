%ifndef __MSR_INC__
%define __MSR_INC__


%define MSR_EFER	0xC0000080

%define EFER_SCE	0x00000001	; system call extensions
%define EFER_LME	0x00000100	; long mode enable
%define EFER_LMA	0x00000400	; long mode active
%define EFER_NXE	0x00000800	; no execute enable
%define EFER_SVME	0x00001000	; secure virtual mode enable
%define EFER_LMSLE	0x00002000	; long mode segment limit enable
%define EFER_FFXSR	0x00004000	; fast FXSAVE/FXRSTOR
%define EFER_TCE	0x00008000	; translation cache extension


%endif ; __MSR_INC__
