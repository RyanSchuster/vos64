%ifndef __GDT_INC__
%define __GDT_INC__


struc gdte_t
			resw 1
			resw 1
			resd 1
	.flags0:	resb 1
	.flags1:	resb 1
			resb 1
endstruc


%define GDTE_NULL		0x0000000000000000
%define GDTE_CODE_CPL0		0x0020980000000000
%define GDTE_DATA_CPL0		0x0000900000000000


%endif ; __GDT_INC__
