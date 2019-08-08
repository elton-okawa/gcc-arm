.global processB
.text

DOIS: .word 0x32

processB:
	LDR r0, =UART0DR
	LDR r0, [r0]
	LDR r1, DOIS
	STR r1, [r0]
	BL wait
	B processB

wait:
	LDR r3, =800000
loop:
	SUB r3, r3, #1
	CMP r3, #0
	BGE loop
	MOV pc, lr
