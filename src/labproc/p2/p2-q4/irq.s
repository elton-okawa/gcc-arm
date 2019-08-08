.global _start
.global linhaA
.global linhaB
.global UART0DR
.text
_start:
	b _Reset							@ posição 0x00 -Reset
	ldr pc, _undefined_instruction		@ posição 0x04 -Intrução não-definida
	ldr pc, _software_interrupt			@ posição 0x08 -Interrupção de Software
	ldr pc, _prefetch_abort				@ posição 0x0C -Prefetch Abort
	ldr pc, _data_abort					@ posição 0x10 -Data Abort
	ldr pc, _not_used					@ posição 0x14 -Não utilizado
	ldr pc, _irq						@ posição 0x18 -Interrupção (IRQ)
	ldr pc, _fiq						@ posição 0x1C -Interrupção(FIQ)

_undefined_instruction: .word undefined_instruction
_software_interrupt: .word software_interrupt
_prefetch_abort: .word prefetch_abort
_data_abort: .word data_abort
_not_used: .word not_used
_irq: .word irq
_fiq: .word fiq
_linhaA: .word linhaA
_linhaB: .word linhaB

INTPND:		.word 0x10140000 	@ Interrupt status register
INTSEL:		.word 0x1014000C 	@ interrupt select register( 0 = irq, 1 = fiq)
INTEN:		.word 0x10140010 	@ interrupt enable register
TIMER0L:	.word 0x101E2000 	@ Timer 0 load register
TIMER0V:	.word 0x101E2004 	@ Timer 0 value registers
TIMER0C:	.word 0x101E2008 	@ timer 0 control register
TIMER0X:	.word 0x101E200c 	@ timer 0 interrupt clear register

UART0DR:	.word 0x101f1000 
SPACE: 		.word 0x20
TIME: 		.word 0xFFFFF

_Reset:
	LDR sp, =stack_top 		@ pilha do SUPERVISOR
	@ processA
	ADD r3, sp, #0x1000 
	LDR r1, _linhaA
	STR r3, [r1, #52] 		@ mem[_linhaA + 12]	= r0 = SP processo A

	LDR r0, =processA
	STR r0, [r1, #60] 		@ mem[_linhaA + 14] = r0 = PC processo A

	MRS r0, cpsr
	BIC r0, r0, #0x80 		@ Ativa as interrupções para o processo
	STR r0, [r1, #64] 		@ mem[_linhaA + 15] = r0 = CPSR SUPERVISOR
	@ processB
	ADD r3, r3, #0x1000 	
	LDR r1, _linhaB
	STR r3, [r1, #52] 		@ mem[_linhaB + 12] = r0 = SP processo B
  		
	LDR r0, =processB
	STR r0, [r1, #60] 		@ mem[_linhaB + 14] = r0 = PC processo B

	MRS r0, cpsr
	BIC r0, r0, #0xF 		@ Transforma em Modo User
	BIC r0, r0, #0x80 		@ Ativa as interrupções para o processo
	STR r0, [r1, #64] 		@ mem[_linhaB + 15] = r0 = CPSR USER

  	MRS r1, cpsr    @ salvando o modo corrente em R0
    MSR cpsr_ctl, #0b11010010 @ alterando o modo para irq - o SP eh automaticamente chaveado ao chavear o modo
    ADD r3, r3, #0x1000
    MOV sp, r3 	@ pilha do irq definida
    MSR cpsr, r1 @ volta para o modo anterior

    MRS r1, cpsr    @ salvando o modo corrente em R0
    MSR cpsr_ctl, #0b11011011 @ alterando o modo para undefined - o SP eh automaticamente chaveado ao chavear o modo
    ADD r3, r3, #0x1000
    MOV sp, r3 	@ pilha do undefined definida
    MSR cpsr, r1 @ volta para o modo anterior

	bl  main
	b   .

undefined_instruction:
	b   do_undefined_interrupt

software_interrupt:
	b   do_software_interrupt 	@ vai para o handler de interrupções de software

prefetch_abort:
	b   .

data_abort:
	b   .

not_used:
	b   .

irq:
	b   do_irq_interrupt 	@ vai para o handler de interrupções IRQ

fiq:
	b   .

do_undefined_interrupt:
	STMFD sp!, {r0-r12, lr}
	LDR r0, =linhaA
	LDR r1, [r0, #52]		@ r1 = SP/processA
	LDMFD sp!, {r0-r12, pc}^

do_software_interrupt:	@Rotina de Interrupçãode software
	add 	r1, r2, r3 	@ r1 = r2 + r3
	mov 	pc, lr 	@ volta p/ o endereço armazenado em r14

do_irq_interrupt: @ Rotina de interrupções IRQ
	SUB 	lr, lr, #4
	@ save estado 1
	STMFD 	sp!, {r0, lr} 		@ empilha o r0, r1 e lr para serem usados

	@ verifica qual o processo a ser salvo
	LDR 	r0, =nproc
	LDR 	r0, [r0]
	CMP 	r0, #0
	LDREQ 	r0, =linhaA			@ r0 = &mem[_linhaA]
	CMP 	r0, #1
	LDREQ 	r0, =linhaB			@ r0 = &mem[_linhaB]
	@ end verificacao

	STR 	lr, [r0, #60]		@ LR/IRQ - 4 = PC/Supervisor = r15, deve ser salvo na posição 4*15 = 60
	BL 		store_registers 	@ salva registradores r1-r14 e r16
	MOV 	r1, r0 				@ r1 = r0 = &mem[_linhaX]
	LDMFD 	sp!, {r0, lr} 		@ recupera r0, r1 e lr

	STR 	r0, [r1]			@ mem[_linhaX] = r0
	LDR 	r1, [r1, #4] 		@ r1 = mem[_linhaX + 1]
	@ load estado 1

	STMFD 	sp!, {r0, lr} 	@ Empilha os registradores
	
	LDR 	r0, INTPND 			@ Carrega o registrador de status de interrupção
	LDR 	r0, [r0]

	TST 	r0, #0x0010 			@ verifica se é uma interupção de timer
	BLNE 	prep_handle_timer 		@ vai para o rotina de tratamento da interrupção de timer
	LDMFD   sp!, {r0, pc}^ 		@ retorna

prep_handle_timer:
	ADD 	sp, sp, #8
	B 		handler_timer 			@ vai para o rotina de tratamento da interrupção de timer

timer_init:
	LDR 	r0, INTEN
	LDR 	r1,	=0x10 		@ bit 4 for timer 0 interrupt enable
	STR 	r1, [r0]

	LDR 	r0, TIMER0L 
	LDR 	r1, =0xFFFFF @ setting timer load
	STR 	r1, [r0]

	LDR 	r0, TIMER0C 
	MOV  	r1, #0xE0 		@ enable timer module
	STR 	r1, [r0]

	mrs 	r0, cpsr 
	bic 	r0, r0, #0x80
	msr 	cpsr_c, r0 		@ enabling interrupts in the cpsr
	mov 	pc, lr

main:
	bl 	timer_init 	@ initialize interrupts and timer 0
	B 	chaveamento

store_registers:
	STMFA 	r0, {r1-r12} 	@ mem[_linha + X] = rX = r1-r12 - FULL ASCENDING

	MRS 	r1, spsr
	STR 	r1, [r0, #64]	@ mem[_linhaA + 16] = CPSR/Y = r16
	
	MRS 	r2, cpsr    			@ salvando o modo corrente em R2
	MOV 	r3, r1 					@ r3 = r1 = CPSR/Y
	BIC 	r3, r3, #0xFFFFFFE0 	@ r3 = isola os últimos 5 bits
	CMP 	r3, #0b10000 			@ r3 = CPSR/Y == Modo User
	ORREQ 	r1, r1, #0b11111			@ transforma r1 em Modo System 			
	ORR 	r1, r1, #0xC0 			@ desabilita interrupções
    MSR 	cpsr, r1 				@ alterando o modo para Y com interrupções desativadas
    STR 	sp, [r0, #52] 			@ mem[_linhaX + 13] = SP/Y = r13
    STR 	lr, [r0, #56] 			@ mem[_linhaX + 14] = LR/Y = r14
    MSR 	cpsr, r2 				@ volta para o modo anterior

	MOV 	pc, lr

linhaA:
	.space 68, 0x0

linhaB:
	.space 68, 0x0
