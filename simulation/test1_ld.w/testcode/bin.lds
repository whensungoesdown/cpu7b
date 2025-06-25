

OUTPUT_ARCH(loongarch)
ENTRY(_start)
SECTIONS
{

  . = 0x1c000000;
  .text ALIGN(0x8):
  {
    _start = . ;
	kernel_entry = . ;
    *(.text)
    *(.rodata*)
    *(.reginfo)
    *(.init)
    *(.stub)

    *(.gnu.warning)
    rodata_end = .;
  } =0

  .data ALIGN(0x8) :
  {
    *(.data)
    *(.data*)
  }

}
