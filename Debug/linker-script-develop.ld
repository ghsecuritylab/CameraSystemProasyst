MEMORY
{
  ROM (rx) : ORIGIN = 0x00000000, LENGTH = 0x02000000
  BOOT_LOADER (rx) : ORIGIN = (0x18000000), LENGTH = (0x00004000)
  SFLASH (rx) : ORIGIN = (0x18000000 + (0x00004000)), LENGTH = (0x800000 - (0x00004000))
  L_TTB (rw) : ORIGIN = 0x20000000, LENGTH = 0x00004000
  RAM (rwx) : ORIGIN = 0x20020000, LENGTH = 0x008E0000
  RAM_NC (rwx) : ORIGIN = 0x20900000, LENGTH = 0x00100000
}
ENTRY(Reset_Handler)
SECTIONS
{
    .boot :
    {
        KEEP(*(.boot_loader))
    } > BOOT_LOADER
    .text :
    {
        Image$$VECTORS$$Base = .;
        * (RESET)
        KEEP(*(.isr_vector))
        *(SVC_TABLE)
        *(.text*)
        KEEP(*(.init))
        KEEP(*(.fini))
        *crtbegin.o(.ctors)
        *crtbegin?.o(.ctors)
        *(EXCLUDE_FILE(*crtend?.o *crtend.o) .ctors)
        *(SORT(.ctors.*))
        *(.ctors)
        *crtbegin.o(.dtors)
        *crtbegin?.o(.dtors)
        *(EXCLUDE_FILE(*crtend?.o *crtend.o) .dtors)
        *(SORT(.dtors.*))
        *(.dtors)
        Image$$VECTORS$$Limit = .;
        Image$$RO_DATA$$Base = .;
        *(.rodata*)
        Image$$RO_DATA$$Limit = .;
        KEEP(*(.eh_frame*))
    } > SFLASH
    .ARM.extab :
    {
        *(.ARM.extab* .gnu.linkonce.armextab.*)
    } > SFLASH
    __exidx_start = .;
    .ARM.exidx :
    {
        *(.ARM.exidx* .gnu.linkonce.armexidx.*)
    } > SFLASH
    __exidx_end = .;
    .copy.table :
    {
        . = ALIGN(8);
        __copy_table_start__ = .;
        LONG (__etext)
        LONG (__data_start__)
        LONG (__data_end__ - __data_start__)
        LONG (__etext2)
        LONG (__nc_data_start)
        LONG (__nc_data_end - __nc_data_start)
        LONG (LOADADDR(.ram_code))
        LONG (ADDR(.ram_code))
        LONG (SIZEOF(.ram_code))
        __copy_table_end__ = .;
    } > SFLASH
    .zero.table :
    {
        . = ALIGN(8);
        __zero_table_start__ = .;
        LONG (__bss_start__)
        LONG (__bss_end__ - __bss_start__)
        LONG (__nc_bss_start)
        LONG (__nc_bss_end - __nc_bss_start)
        __zero_table_end__ = .;
    } > SFLASH
    .ram_code : ALIGN( 0x8 ) {
        __ram_code_load = .;
        __ram_code_start = LOADADDR(.ram_code) + ( __ram_code_load - ADDR(.ram_code) );
        *(RAM_CODE)
        *(RAM_CONST)
        . = ALIGN( 0x8 );
        __ram_code_end = LOADADDR(.ram_code) + ( . - ADDR(.ram_code) );
    } > RAM AT > SFLASH
    Load$$SEC_RAM_CODE$$Base = LOADADDR(.ram_code);
    Image$$SEC_RAM_CODE$$Base = ADDR(.ram_code);
    Load$$SEC_RAM_CODE$$Length = SIZEOF(.ram_code);
    .ttb :
    {
        Image$$TTB$$ZI$$Base = .;
        . += 0x00004000;
        Image$$TTB$$ZI$$Limit = .;
    } > L_TTB
    __etext = Load$$SEC_RAM_CODE$$Base + SIZEOF(.ram_code);
    .data : AT (__etext)
    {
        Image$$RW_DATA$$Base = .;
        __data_start__ = .;
        *(vtable)
        *(.data*)
        Image$$RW_DATA$$Limit = .;
        . = ALIGN(8);
        PROVIDE (__preinit_array_start = .);
        KEEP(*(.preinit_array))
        PROVIDE (__preinit_array_end = .);
        . = ALIGN(8);
        PROVIDE (__init_array_start = .);
        KEEP(*(SORT(.init_array.*)))
        KEEP(*(.init_array))
        PROVIDE (__init_array_end = .);
        . = ALIGN(8);
        PROVIDE (__fini_array_start = .);
        KEEP(*(SORT(.fini_array.*)))
        KEEP(*(.fini_array))
        PROVIDE (__fini_array_end = .);
        . = ALIGN(8);
        __data_end__ = .;
    } > RAM
    .bss ALIGN(0x10):
    {
        Image$$RW_IRAM1$$Base = .;
        __bss_start__ = .;
        *(.bss*)
        *(COMMON)
        __bss_end__ = .;
        Image$$RW_IRAM1$$Limit = .;
    } > RAM
    .heap :
    {
        __end__ = .;
        end = __end__;
        *(.heap*)
    } > RAM
    .stack_dummy (COPY):
    {
        *(.stack*)
    } > RAM
    __StackTop = ORIGIN(RAM) + LENGTH(RAM);
    _estack = __StackTop;
    __StackLimit = __StackTop - SIZEOF(.stack_dummy);
    __HeapLimit = __StackLimit;
    PROVIDE(__stack = __StackTop);
    ASSERT(__StackLimit >= __HeapLimit, "region RAM overflowed with stack")
    __etext2 = __etext + SIZEOF(.data);
    .nc_data : AT (__etext2)
    {
        Image$$RW_DATA_NC$$Base = .;
        __nc_data_start = .;
        *(NC_DATA)
        . = ALIGN(8);
        __nc_data_end = .;
        Image$$RW_DATA_NC$$Limit = .;
    } > RAM_NC
    .nc_bss (NOLOAD) :
    {
        Image$$ZI_DATA_NC$$Base = .;
        __nc_bss_start = .;
        *(NC_BSS)
        . = ALIGN(8);
        __nc_bss_end = .;
        Image$$ZI_DATA_NC$$Limit = .;
    } > RAM_NC
}
