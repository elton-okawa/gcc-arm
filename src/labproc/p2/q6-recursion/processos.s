.global processA
.global processB
.text

UM: .word 0x31
DOIS: .word 0x32
SEIS: .word 0x36

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
	LDR r2, SEIS
	BL recB
	BL wait
	B processB
recB:
	CMP r2, #0x30
	MOVLE pc, lr
	STMFD sp!, {r2, lr}
	SUB r2, r2, #1
	BL recB
	LDMFD sp!, {r2, lr}
	STR r2, [r0]
	MOV pc, lr
	
wait:
	LDR r3, =800000
loop:
	SUB r3, r3, #1
	CMP r3, #0
	BGE loop
	MOV pc, lr
