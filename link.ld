/*

TODO:
use MEMORY command to not step on ROM areas if it gets too big
make sure load and virtual addresses match up
test addresses of text, data, bss, etc.
test fill value of uninitialized data (want zeros)
move addresses and relo info into include files and test relos

*/

ENTRY(StraponEntry)
OUTPUT_FORMAT("elf32-i386")
/*OUTPUT_FORMAT("elf32-x86-64")*/	/* invalid arch-dependent ELF magic */
/*OUTPUT_FORMAT("elf64-x86-64")*/	/* out-of-memory */

SECTIONS
{
	/* 32-bit to 64-bit stage */

	. = straponAddr;

	.strapon ALIGN(4K) : AT(ADDR(.strapon))
	{
		/* multiboot header needs to come first */
		*(.straponHeaders)
		*(.straponText)
		*(.straponData)
	} = 0x41414141

	.straponBss ALIGN(4K) : AT(ADDR(.straponBss))
	{
		*(.straponBss)
	} = 0x00000000


	/* kernel proper */

	. = kernAddrVirt;

	.text ALIGN(4K) : AT(ADDR(.text) - remapOffset)
	{
		/*loadAddrBegin = .;*/
		text = ADDR(.text);

		*(.text)
		*(.rodata*)
	} = 0x41414141

	.data ALIGN(4K) : AT(ADDR(.data) - remapOffset)
	{
		data = ADDR(.data);

		*(.data)
	} = 0x41414141

	.bss ALIGN(4K) : AT(ADDR(.bss) - remapOffset)
	{
		bss = ADDR(.bss);

		*(.bss)
		*(COMMON)
	} = 0x00000000

	.reclaim ALIGN(4K) : AT(ADDR(.reclaim) - remapOffset)
	{
		reclaim = ADDR(.reclaim);

		*(.reclaimText)
		*(.reclaimData)
	} = 0x41414141

	.reclaimBss ALIGN(4K) : AT(ADDR(.reclaimBss) - remapOffset)
	{
		reclaimBss = ADDR(.reclaimBss);

		*(.reclaimBss)
	}= 0x00000000


	/* end! */

	. = ALIGN(4K);
	kernSize = . - kernAddrVirt;
}
