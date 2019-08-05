ENTRY(_start)
SECTIONS
{
	. = 0x0;
	.text : { irq.o handler.o * (.text); }
	. = ALIGN(8);
 	. = . + 0x1000; /* 4kB of stack memory */
 	stack_top = .;
}