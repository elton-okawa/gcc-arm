.global processA
.global processB
.text

UM: .word 0x31
DOIS: .word 0x32

processA:
	LDR r0, =UART0DR 	@ carrega o endereço da constante UART0DR
	LDR r0, [r0]		@ carrega o valor da constante UART0DR
	LDR r1, UM
	STR r1, [r0]
	BL wait
	B processA

processB:
	LDR r0, =UART0DR
	LDR r0, [r0]
	LDR r1, DOIS
	STR r1, [r0]
	.word 0xFFFFFFFF
	BL wait
	B processB

wait:
	LDR r3, =800000
loop:
	SUB r3, r3, #1
	CMP r3, #0
	BGE loop
	MOV pc, lr
