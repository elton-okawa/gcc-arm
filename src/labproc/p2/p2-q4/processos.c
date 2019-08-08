volatile unsigned int * const TIMER0X = (unsigned int *)0x101E200c;
 
volatile unsigned int * const UART0DR_C = (unsigned int *)0x101f1000;
 
void print_uart0(const char *s) {
 while(*s != '\0') { /* Loop until end of string */
 *UART0DR_C = (unsigned int)(*s); /* Transmit char */
 s++; /* Next char */
 }
}

void sleep(int clocks) {
	int i;
	for (i = 0; i < clocks; i++) {}
}

void processA() {
	// *TIMER0X = 0;
	while (1) {
		print_uart0("9836579");
		__asm__(".word 0xFFFFFFFF");
		sleep(1000000);
	}
}

void handle_undefined_c() {
	print_uart0("invalido");
}