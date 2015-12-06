%ifndef __DEFS_CREG_H__
%define __DEFS_CREG_H__


%define CR0_PE		0x00000001	;protected mode enable
%define CR0_MP		0x00000002	;monitor coprocessor
%define CR0_EM		0x00000004	;no x87 floating-point coprocessor attached (emulate)
%define CR0_TS		0x00000008	;task switched - for x87 state stuff
%define CR0_ET		0x00000010	;extension type - 80287 or 80387 (for the old 386)
%define CR0_NE		0x00000020	;numeric error reporting (x87 internal when set)
%define CR0_WP		0x00010000	;enable page write-only protection
%define CR0_AM		0x00040000	;alignment mask - allow alignment checks
%define CR0_NW		0x20000000	;not writethrough - enable/disable writeback caching
%define CR0_CD		0x40000000	;globally disable cache
%define CR0_PG		0x80000000	;enable paging


%define CR4_VME		0x00000001	;virtual 8086 mode extensions - enables virtual interrupt flag
%define CR4_PVI		0x00000002	;enable protected mode virtual interrupts
%define CR4_TSD		0x00000004	;disable timestamp counter for rings lower than 0
%define CR4_DE		0x00000008	;enable debug register i/o space breakpoints
%define CR4_PSE		0x00000010	;enable page size extensions (big pages)
%define CR4_PAE		0x00000020	;enable physical address extension
%define CR4_MCE		0x00000040	;enable machine check exceptions
%define CR4_PGE		0x00000080	;enable global pages
%define CR4_PCE		0x00000100	;enable RDPMC for rings lower than 0
%define CR4_OSFXSR	0x00000200	;enable SSE instructions and FXSAVE and FXRSTOR
%define CR4_OSXMMEXCPT	0x00000400	;enable unmasked SSE exceptions
%define CR4_VMXE	0x00002000	;enable virtual mode extensions
%define CR4_SMXE	0x00004000	;enable safer mode extensions
%define CR4_PCIDE	0x00020000	;enable PCIDs (process context identifiers)
%define CR4_OSXSAVE	0x00040000	;enable XSAVE and processor extended states
%define CR4_SMEP	0x00100000	;enable supervisor mode executeion protection
%define CR4_SMAP	0X00200000	;enable supervisor mode access protection


%endif ;__DEFS_CREG_H__
