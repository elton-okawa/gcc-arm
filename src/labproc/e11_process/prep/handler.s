.global handler_timer
.text

TIMER0X:	.word 0x101E200c 	@ timer 0 interrupt clear register
HASHTAG: 	.word 0x23 
UART0DR:	.word 0x101f1000 

handler_timer:
	LDR 	r0, TIMER0X
	MOV 	r1, #0x0
	STR 	r1, [r0] 	@ Escreve no registrador TIMER0X para limpar o pedido de interrupção
	LDR 	r0, UART0DR
	LDR 	r1, HASHTAG
	STR 	r1, [r0] 	@ Print #
	B 		recover_registers
	@ Inserir código que será executado na interrupção de timer aqui (chaveamento de processos,  ou alternar LED por exemplo)
	MOV 	pc, lr

recover_registers:
	LDR 	r1, =linhaA			@ r1 = &mem[_linhaA]
	LDR 	r0, [r1, #64] 		@ r0 = mem[_linha + 16] = CPSR/Supervisor
	MSR 	spsr, r0 			@ SPSR/IRQ = CPSR/Supervisor

	MRS 	r0, cpsr 			@ r0 = cpsr atual = IRQ
    MSR 	cpsr_ctl, #0b11010011 	@ alterando o modo para supervisor com interrupções desativadas
    LDR 	sp, [r1, #52] 		@ mem[_linhaA + 13] = SP/Supervisor = r13
    LDR 	lr, [r1, #56] 		@ mem[_linhaA + 14] = LR/Supervisor = r14
    MSR 	cpsr, r0 			@ CPSR = r0 = IRQ 

    LDR 	r0, [r1, #60] 		@ r0 = mem[_linhaA + 15] = PC/Supervisor
    STMFD	sp!, {r0} 			@ empilha o PC/Supervisor

    LDR 	r1, =linhaA 		@ r1 = &mem[_linhaA]
    LDMFD 	r1, {r0-r12} 		@ rX = mem[_linhaA + X]
    STMFD 	sp!, {r0-r12} 		@ empilha r0-r12
    
    LDMFD 	sp!, {r0-r12, pc}^ 	@ recupera todos

