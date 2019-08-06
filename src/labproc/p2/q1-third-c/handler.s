.global handler_timer
.global chaveamento
.global nproc
.text

TIMER0X:	.word 0x101E200c 	@ timer 0 interrupt clear register

nproc: 		.word 0x0

handler_timer:
	LDR 	r0, TIMER0X
	MOV 	r1, #0x0
	STR 	r1, [r0] 	@ Escreve no registrador TIMER0X para limpar o pedido de interrupção
	B 		chaveamento
	
chaveamento:
	LDR 	r2, =nproc
	LDR 	r0, [r2]
	CMP 	r0, #0
	LDREQ 	r1, =linhaB			@ r1 = &mem[_linhaB]
	CMP 	r0, #1
	LDREQ 	r1, =linhaC 		@ r1 = &mem[_linhaC]
	CMP 	r0, #2
	LDREQ 	r1, =linhaA			@ r1 = &mem[_linhaA]
	BL 		toggle_nproc
	B 		recover_registers

toggle_nproc:
	ADD 	r0, r0, #1
	CMP 	r0, #3
	LDRGE 	r0, =0
	STR 	r0, [r2]
	MOV 	pc, lr

recover_registers:
	LDR 	r0, [r1, #64] 		@ r0 = mem[_linhaX + 16] = CPSR/Y
	MSR 	spsr, r0 			@ SPSR/IRQ = CPSR/Y

	MRS 	r2, cpsr 			@ r2 = cpsr atual = IRQ

	MOV 	r3, r0
	BIC 	r3, r3, #0xFFFFFFE0 	@ r0 = isola os últimos 5 bits
	CMP 	r3, #0b10000 			@ r0 = CPSR/Y == Modo User
	ORREQ 	r0, r0, #0b11111		@ transforma r0 em Modo System 			
	
    MSR 	cpsr, r0 			@ alterando o modo para Y com interrupções desativadas
    LDR 	sp, [r1, #52] 		@ mem[_linhaX + 13] = SP/Y = r13
    LDR 	lr, [r1, #56] 		@ mem[_linhaX + 14] = LR/Y = r14
    MSR 	cpsr, r2 			@ CPSR = r2 = IRQ 

    LDR 	r0, [r1, #60] 		@ r0 = mem[_linhaX + 15] = PC/X
    STMFD	sp!, {r0} 			@ empilha o PC/Y

    LDMFD 	r1, {r0-r12} 		@ rX = mem[_linhaX + X]
    STMFD 	sp!, {r0-r12} 		@ empilha r0-r12
    
    LDMFD 	sp!, {r0-r12, pc}^ 	@ recupera todos

