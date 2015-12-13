%define MOD_SERIAL
; module: Serial


%include "debug/serial.inc"



;------------------------------------------------------------------------------
; Local macro constants
;
; Got a bit carried away here...

; Default base addresses (don't trust these)
%define PORT_COM1		0x03F8
%define PORT_COM2		0x02F8
%define PORT_COM3		0x03E8
%define PORT_COM4		0x02E8


; Register offsets
%define COM_RBR_THR		0x0000		;DLAB = 0, receive buffer/transmit holding register
%define COM_IER			0x0001		;DLAB = 0, interrupt enable
%define COM_DL_LSB		0x0000		;DLAB = 1, divisor latch lsb
%define COM_DL_MSB		0x0001		;DLAB = 1, divisor latch msb
%define COM_IIR_FCR		0x0002		;interrupt identifier/fifo control register
%define COM_LCR			0x0003		;line control register
%define COM_MCR			0x0004		;modem control register
%define COM_LSR			0x0005		;line status register
%define COM_MSR			0x0006		;modem status register
%define COM_SCR			0x0007		;scratch register


; Register bitfields
%define IER_ERBFI		0x01		;enable receive buffer full interrupt
%define IER_ETBEI		0x02		;enable transmitter buffer empty interrupt
%define IER_ELSI		0x04		;enable line status interrupt, interrupts on rx errors
%define IER_EDSSI		0x08		;enable delta status signals interrupt

%define DL_115200		0x0001		;is this enough bauds for you?
%define DL_57600		0x0002
%define DL_38400		0x0003
%define DL_19200		0x0006
%define DL_9600			0x000C
%define DL_7200			0x0010
%define DL_4800			0x0018
%define DL_3600			0x0020
%define DL_2400			0x0030
%define DL_2000			0x003A
%define DL_1800			0x0040
%define DL_1200			0x0060
%define DL_600			0x00C0
%define DL_300			0x0180
%define DL_150			0x0300
%define DL_134P5		0x0359
%define DL_110			0x0417
%define DL_75			0x0600
%define DL_50			0x0900

%define IIR_PEND		0x01		;interrupt pending if zero
%define IIR_IID_MASK		0x0E		;interrupt id mask
%define IIR_IID_STAT		0x06		;status interrupt	highest
%define IIR_IID_RX		0x04		;rx buf full		second highest
%define IIR_IID_FIFO		0x0C		;no rx, buf fifo full	second highest
%define IIR_IID_TX		0x02		;tx buf empty		third highest
%define IIR_IID_MODEM		0x00		;delta flags set	lowest
%define IIR_FIFO_EN		0xC0

%define FCR_ENABLE		0x01		;enable fifos
%define FCR_RFRES		0x02		;receive fifo reset
%define FCR_TFRES		0x04		;transmit fifo reset
%define FCR_DMASEL		0x08		;DMA mode select - don't know what this is...
%define FCF_RXTRIG_MASK		0xC0		;number of bytes before rx interrupt is triggered
%define FCR_RXTRIG_1		0x00
%define FCR_RXTRIG_4		0x40
%define FCR_RXTRIG_8		0x80
%define FCR_RXTRIG_14		0xC0

%define LCR_SIZE_MASK		0x03		;for pulling out all size bits
%define LCR_SIZE_5BIT		0x00
%define LCR_SIZE_6BIT		0x01
%define LCR_SIZE_7BIT		0x02
%define LCR_SIZE_8BIT		0x03
%define LCR_1STOP		0x00
%define LCR_2STOP		0x04		;long (2 or 1.5) stop bits
%define LCR_PARITY_MASK		0x38		;for pulling out all parity bits
%define LCR_PARITY_NONE		0x00
%define LCR_PARITY_ODD		0x08
%define LCR_PARITY_EVEN		0x18
%define LCR_PARITY_MARK		0x28
%define LCR_PARITY_SPACE	0x38
%define LCR_SBR			0x40		;set break
%define LCR_DLAB		0x80		;divisor latch access bit, selects funcion of registers 0 and 1

%define MCR_DTR			0x01		;data terminal ready
%define MCR_RTS			0x02		;request to send
%define MCR_OUT_1		0x04		;don't know, just write a 1 to it
%define MCR_OUT_2		0x08		;enable interrupts? just write a 1 to it
%define MCR_LOOP		0x10		;local loopback for self-test

%define LSR_RBF			0x01		;receiver buffer full (data available)
%define LSR_OE			0x02		;overrun error
%define LSR_PE			0x04		;parity error
%define LSR_FE			0x08		;framing error
%define LSR_BREAK		0x10		;broken line detected
%define LSR_THRE		0x20		;transmitter holding register empty
%define LSR_TEMT		0x40		;transmitter empty
%define LSR_FIFOERR		0x80		;at least one error in the rx fifo chain

%define MSR_DCTS		0x01		;data clear to send
%define MSR_DDSR		0x02		;delta data set ready
%define MSR_TERI		0x04		;trailing edge ring indicator
%define MSR_DDCD		0x08		;delta data carrier detect
%define MSR_CTS			0x10		;clear to send
%define MSR_DSR			0x20		;data set ready
%define MSR_RI			0x40		;ring indicator
%define MSR_DCD			0x80		;data carrier detect



[section .text]
[bits 64]


[global SerialInit]
SerialInit:
	push	rax
	push	rdx

	; Disable interrupts
	xor	al, al
	mov	dx, PORT_COM1 + COM_LCR
	out	dx, al				;clear DLAB just in case
	mov	dx, PORT_COM1 + COM_IER
	out	dx, al

	; Set the DLAB bit so we can set the baud rate
	mov	dx, PORT_COM1 + COM_LCR
	mov	al, LCR_DLAB
	out	dx, al

	; Set baud to 115200 (divisor of 1)
	mov	dx, PORT_COM1 + COM_DL_LSB
	mov	ax, DL_115200
	out	dx, ax

	; Set trigger threshold, reset, and enable fifos
	mov	dx, PORT_COM1 + COM_IIR_FCR
	mov	al, FCR_RXTRIG_14 | FCR_TFRES | FCR_RFRES | FCR_ENABLE
	out	dx, al

	; Clear DLAB and set the line properties
	mov	dx, PORT_COM1 + COM_LCR
	mov	al, LCR_PARITY_NONE | LCR_1STOP | LCR_SIZE_8BIT
	out	dx, al

	pop	rdx
	pop	rax
	ret


[global SerialPutChar]
SerialPutChar:
	push	rax
	push	rdx

	mov	ah, al

	; Wait until the tx buffer is empty
.wait:
	mov	dx, PORT_COM1 + COM_LSR
	in	al, dx
	test	al, LSR_THRE
	jz	.wait

	; Write the character
	mov	al, ah
	mov	dx, PORT_COM1 + COM_RBR_THR
	out	dx, al

	pop	rdx
	pop	rax
	ret


[global SerialClrScr]
SerialClrScr:
	push	rax

	; Do something here?

	pop	rax
	ret


[section .data]



[section .bss]
