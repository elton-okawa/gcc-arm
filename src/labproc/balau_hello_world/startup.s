.section INTERRUPT_VECTOR, "x"
.global _Reset
_Reset:
  B Reset_Handler /* Reset */
  B Undefined_Handler /* Undefined */
  B . /* SWI */
  B . /* Prefetch Abort */
  B . /* Data Abort */
  B . /* reserved */
  B . /* IRQ */
  B . /* FIQ */
 
Reset_Handler:
  LDR sp, =stack_top
  MRS r0, cpsr    @ salvando o modo corrente em R0
	MSR cpsr_ctl, #0b11011011 @ alterando o modo para undefined - o SP eh automaticamente chaveado ao chavear o modo
	LDR sp, =undefined_stack_top @ a pilha de undefined eh setada 
	MSR cpsr, r0 @ volta para o modo anterior
	MSR cpsr_ctl, #0b00010000 @ modo usuário (I = 0 (ativa normal interrupt), F = 0 (ativa fast interrupt), T = 0 (executar 32 bit arm instruction), MOD = 10000 (User)
	MSR cpsr_ctl, #0b00010001 @ modo Fast Interrupt
	MSR cpsr_ctl, #0b00010010 @ modo Interrupt
	MSR cpsr_ctl, #0b00010011 @ modo Supervisor
	MSR cpsr_ctl, #0b00010111 @ modo Abort
	MSR cpsr_ctl, #0b00011011 @ modo Undefined
	MSR cpsr_ctl, #0b00011111 @ modo System

  B .

Undefined_Handler:
	STMFD sp!,{R0-R12,lr}
	BL undefined
	LDMFD sp!,{R0-R12,pc}^

