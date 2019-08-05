volatile unsigned int * const TIMER0X = (unsigned int *)0x101E200c;
 
volatile unsigned int * const UART0DR = (unsigned int *)0x101f1000;
 
void print_uart0(const char *s) {
 while(*s != '\0') { /* Loop until end of string */
 *UART0DR = (unsigned int)(*s); /* Transmit char */
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
		print_uart0("1");
		sleep(1000000);
	}
}

void processB() {
	// *TIMER0X = 0;
	while(1) {
		print_uart0("2");
		sleep(1000000);
	}
}
