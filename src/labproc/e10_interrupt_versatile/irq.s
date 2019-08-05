.global _start
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
	LDR sp, =stack_top
  	MRS r0, cpsr    @ salvando o modo corrente em R0
    MSR cpsr_ctl, #0b11010010 @ alterando o modo para irq - o SP eh automaticamente chaveado ao chavear o modo
    LDR r1, =stack_top @ a pilha de irq eh setada
    ADD r1, r1, #0x1000
    MOV sp, r1 	@ pilha do irq definida
    MSR cpsr, r0 @ volta para o modo anterior

	bl  main
	b   .

undefined_instruction:
	b   .

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

do_software_interrupt:	@Rotina de Interrupçãode software
	add 	r1, r2, r3 	@ r1 = r2 + r3
	mov 	pc, lr 	@ volta p/ o endereço armazenado em r14

do_irq_interrupt: @ Rotina de interrupções IRQ
	SUB 	lr, lr, #4
	STMFD 	sp!, {r0-r3, lr} 	@ Empilha os registradores
	LDR 	r0, INTPND 			@ Carrega o registrador de status de interrupção
	LDR 	r0, [r0]

	TST 	r0, #0x0010 			@ verifica se é uma interupção de timer
	BLNE 	handler_timer 			@ vai para o rotina de tratamento da interrupção de timer
	LDMFD   sp!, {r0-r3,pc}^ 		@ retorna

timer_init:
	LDR 	r0, INTEN
	LDR 	r1,	=0x10 		@ bit 4 for timer 0 interrupt enable
	STR 	r1, [r0]

	LDR 	r0, TIMER0L 
	MOV 	r1, #0xff 		@ setting timer value
	STR 	r1, [r0]

	LDR 	r0, TIMER0C
	LDR 	r1, [r0] 
	MOV  	r1, #0xA0 		@ enable timer module
	STR 	r1, [r0]

	mrs 	r0, cpsr
	bic 	r0, r0, #0x80
	msr 	cpsr_c, r0 		@ enabling interrupts in the cpsr
	mov 	pc, lr

main:
	bl 	timer_init 	@ initialize interrupts and timer 0
	LDR 	r0, UART0DR
	LDR 	r1, SPACE 
	LDR 	r3, TIME
	bl 	print_hello_world
	b 	print

print_hello_world:
	LDR 	r2, =0x48  @ H
	STR 	r2, [r0]
	LDR 	r2, =0x65  @ e
	STR 	r2, [r0]
	LDR 	r2, =0x6C  @ l
	STR 	r2, [r0]
	LDR 	r2, =0x6C  @ l
	STR 	r2, [r0]
	LDR 	r2, =0x6F  @ o
	STR 	r2, [r0]
	LDR 	r2, =0x20  @ ' '
	STR 	r2, [r0]
	LDR 	r2, =0x57  @ W
	STR 	r2, [r0]
	LDR 	r2, =0x6F  @ o
	STR 	r2, [r0]
	LDR 	r2, =0x72  @ r
	STR 	r2, [r0]
	LDR 	r2, =0x6C  @ l
	STR 	r2, [r0]
	LDR 	r2, =0x64  @ d
	STR 	r2, [r0]
	MOV 	pc, lr

print:
	STR 	r1, [r0]
	LDR 	r2, =0
	bl wait
	b print

wait:
	ADD 	r2, r2, #1
	CMP 	r2, r3
	BNE 	wait
	MOV 	pc, lr
