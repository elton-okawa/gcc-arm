.global processB
.text

DOIS: 		.word 0x32 
UART0DR:	.word 0x101f1000 

processB:
	LDR 	r0, UART0DR
	LDR 	r1, DOIS
	STR 	r1, [r0] 	@ Print 2
	B processB
